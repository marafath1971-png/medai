import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Analytics')
@Controller('analytics')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AnalyticsController {
  constructor(private analyticsService: AnalyticsService) {}

  @Get('adherence')
  @ApiOperation({ summary: 'Get adherence score' })
  @ApiQuery({ name: 'days', required: false, example: 30 })
  @ApiResponse({ status: 200, description: 'Adherence score retrieved' })
  async getAdherence(@Request() req: any, @Query('days') days?: number) {
    return this.analyticsService.getAdherenceScore(req.user.id, days || 30);
  }

  @Get('streak')
  @ApiOperation({ summary: 'Get current streak' })
  @ApiResponse({ status: 200, description: 'Streak data retrieved' })
  async getStreak(@Request() req: any) {
    return this.analyticsService.getStreak(req.user.id);
  }

  @Get('body-impact')
  @ApiOperation({ summary: 'Get body impact score' })
  @ApiResponse({ status: 200, description: 'Body impact retrieved' })
  async getBodyImpact(@Request() req: any) {
    return this.analyticsService.getBodyImpact(req.user.id);
  }

  @Get('ai-coach')
  @ApiOperation({ summary: 'Get AI coach insights' })
  @ApiResponse({ status: 200, description: 'AI coach insights retrieved' })
  async getAICoach(@Request() req: any) {
    return this.analyticsService.getAICoach(req.user.id);
  }

  @Get('weekly')
  @ApiOperation({ summary: 'Get weekly statistics' })
  @ApiResponse({ status: 200, description: 'Weekly stats retrieved' })
  async getWeeklyStats(@Request() req: any) {
    return this.analyticsService.getWeeklyStats(req.user.id);
  }
}