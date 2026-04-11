import { Controller, Post, Get, Body, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, AuthResponseDto, OAuthDto, RefreshTokenDto, ForgotPasswordDto, ResetPasswordDto } from './dto/auth.dto';
import { Public } from './decorators/public.decorator';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, description: 'User registered successfully' })
  @ApiResponse({ status: 409, description: 'Email already registered' })
  async register(@Body() dto: RegisterDto): Promise<AuthResponseDto> {
    return this.authService.register(dto);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with email and password' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  @ApiResponse({ status: 401, description: 'Invalid credentials' })
  async login(@Body() dto: LoginDto): Promise<AuthResponseDto> {
    return this.authService.login(dto);
  }

  @Public()
  @Post('login/google')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with Google OAuth' })
  @ApiResponse({ status: 200, description: 'Google login successful' })
  async loginWithGoogle(@Body() dto: OAuthDto): Promise<AuthResponseDto> {
    // In a real implementation, you'd verify the Google ID token
    const mockProfile = {
      email: 'googleuser@gmail.com',
      firstName: 'Google',
      lastName: 'User',
    };
    return this.authService.validateOAuthUser(mockProfile, 'GOOGLE');
  }

  @Public()
  @Post('login/apple')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with Apple OAuth' })
  @ApiResponse({ status: 200, description: 'Apple login successful' })
  async loginWithApple(@Body() dto: OAuthDto): Promise<AuthResponseDto> {
    // In a real implementation, you'd verify the Apple ID token
    const mockProfile = {
      email: 'appleuser@icloud.com',
      firstName: 'Apple',
      lastName: 'User',
    };
    return this.authService.validateOAuthUser(mockProfile, 'APPLE');
  }

  @Public()
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Request password reset' })
  @ApiResponse({ status: 200, description: 'Password reset email sent' })
  async forgotPassword(@Body() dto: ForgotPasswordDto): Promise<{ success: boolean; message: string }> {
    // In a real implementation, you'd send a password reset email
    return { success: true, message: 'Password reset email sent' };
  }

  @Public()
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reset password with token' })
  @ApiResponse({ status: 200, description: 'Password reset successful' })
  async resetPassword(@Body() dto: ResetPasswordDto): Promise<{ success: boolean; message: string }> {
    // In a real implementation, you'd verify the token and update the password
    return { success: true, message: 'Password reset successful' };
  }

  @Public()
  @Post('verify-email')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify email with token' })
  @ApiResponse({ status: 200, description: 'Email verified successfully' })
  async verifyEmail(@Body() dto: { token: string }): Promise<{ success: boolean; message: string }> {
    // In a real implementation, you'd verify the email verification token
    return { success: true, message: 'Email verified successfully' };
  }

  @Public()
  @Post('refresh-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token' })
  @ApiResponse({ status: 200, description: 'Tokens refreshed' })
  async refreshToken(@Body() dto: RefreshTokenDto): Promise<{ accessToken: string; refreshToken: string }> {
    // In a real implementation, you'd verify the refresh token
    return { accessToken: 'new-access-token', refreshToken: 'new-refresh-token' };
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Logout user' })
  @ApiResponse({ status: 200, description: 'Logout successful' })
  async logout(@Request() req: any): Promise<{ success: boolean; message: string }> {
    await this.authService.logout(req.user.id);
    return { success: true, message: 'Logout successful' };
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'User profile retrieved' })
  async getProfile(@Request() req: any): Promise<AuthResponseDto> {
    return this.authService.getProfile(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post('enable-2fa')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Enable two-factor authentication' })
  async enable2FA(@Request() req: any): Promise<{ success: boolean; secret?: string; qrCodeUrl?: string }> {
    // In a real implementation, you'd generate and return 2FA secret
    return { success: true, secret: 'JBSWY3DPEHPK3PXP', qrCodeUrl: 'https://api.qrserver.com/v1/create-qr-code/?data=otpauth://totp/MedTrack:user@medtrack.ai?secret=JBSWY3DPEHPK3PXP' };
  }

  @UseGuards(JwtAuthGuard)
  @Post('verify-2fa')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Verify two-factor authentication code' })
  async verify2FA(@Body() dto: { code: string }): Promise<{ success: boolean; message: string }> {
    // In a real implementation, you'd verify the 2FA code
    return { success: true, message: '2FA enabled' };
  }

  @UseGuards(JwtAuthGuard)
  @Post('disable-2fa')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Disable two-factor authentication' })
  async disable2FA(@Body() dto: { code: string }): Promise<{ success: boolean; message: string }> {
    return { success: true, message: '2FA disabled' };
  }
}