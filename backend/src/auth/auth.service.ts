import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto, LoginDto, AuthResponseDto } from './dto/auth.dto';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponseDto> {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);
    
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        passwordHash,
        firstName: dto.firstName,
        lastName: dto.lastName,
        phone: dto.phone,
        authProvider: 'EMAIL',
      },
    });

    const tokens = await this.generateTokens(user.id, user.email);
    
    return {
      success: true,
      message: 'Registration successful',
      data: {
        user: this.sanitizeUser(user),
        ...tokens,
      },
    };
  }

  async login(dto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const tokens = await this.generateTokens(user.id, user.email);
    
    return {
      success: true,
      message: 'Login successful',
      data: {
        user: this.sanitizeUser(user),
        ...tokens,
      },
    };
  }

  async validateOAuthUser(profile: any, provider: 'GOOGLE' | 'APPLE'): Promise<AuthResponseDto> {
    let user = await this.prisma.user.findUnique({
      where: { email: profile.email },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email: profile.email,
          firstName: profile.firstName || profile.name?.split(' ')[0] || 'User',
          lastName: profile.lastName || profile.name?.split(' ').slice(1).join(' ') || '',
          authProvider: provider,
          emailVerified: true,
        },
      });
    }

    const tokens = await this.generateTokens(user.id, user.email);
    
    return {
      success: true,
      message: `${provider} login successful`,
      data: {
        user: this.sanitizeUser(user),
        ...tokens,
      },
    };
  }

  async getProfile(userId: string): Promise<AuthResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return {
      success: true,
      data: {
        user: this.sanitizeUser(user),
        accessToken: '',
        refreshToken: '',
      },
    };
  }

  async refreshTokens(userId: string): Promise<{ accessToken: string; refreshToken: string }> {
    return this.generateTokens(userId, '');
  }

  async logout(userId: string): Promise<void> {
    // In a more complete implementation, you'd invalidate the refresh token
    // For now, the client will simply discard the tokens
  }

  private async generateTokens(userId: string, email: string) {
    const payload = { sub: userId, email };
    
    const accessToken = this.jwtService.sign(payload, { expiresIn: '15m' });
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    return { accessToken, refreshToken };
  }

  private sanitizeUser(user: any) {
    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      emailVerified: user.emailVerified,
      twoFactorEnabled: user.twoFactorEnabled,
      authProvider: user.authProvider,
      createdAt: user.createdAt,
    };
  }
}