import { Controller, Post, Get, Body, UseGuards, Request, UploadedFile, UseInterceptors, BadRequestException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('AI')
@Controller('ai')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AiController {
  constructor(private aiService: AiService) {}

  @Post('analyze-prescription')
  @ApiOperation({ summary: 'Analyze prescription image using AI' })
  @ApiResponse({ status: 200, description: 'Prescription analyzed successfully' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('image'))
  async analyzePrescription(@UploadedFile() file: any, @Request() req: any) {
    if (!file) {
      throw new BadRequestException('Image file is required');
    }
    return this.aiService.analyzePrescription(file.path);
  }

  @Post('identify-pill')
  @ApiOperation({ summary: 'Identify pill from image using AI' })
  @ApiResponse({ status: 200, description: 'Pill identified successfully' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('image'))
  async identifyPill(@UploadedFile() file: any, @Request() req: any) {
    if (!file) {
      throw new BadRequestException('Image file is required');
    }
    return this.aiService.identifyPill(file.path);
  }

  @Get('insights')
  @ApiOperation({ summary: 'Get AI-powered insights' })
  @ApiResponse({ status: 200, description: 'Insights retrieved successfully' })
  async getInsights(@Request() req: any): Promise<any> {
    return this.aiService.getInsights(req.user.id);
  }

  @Post('analyze-symptoms')
  @ApiOperation({ summary: 'Analyze reported symptoms' })
  @ApiResponse({ status: 200, description: 'Symptoms analyzed successfully' })
  async analyzeSymptoms(@Body() dto: { symptoms: string }): Promise<any> {
    return this.aiService.analyzeSymptoms(dto.symptoms);
  }
}