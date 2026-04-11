import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { DoseLogsService } from './dose-logs.service';
import { CreateDoseLogDto, UpdateDoseLogDto, DoseLogResponseDto } from './dto/dose-log.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Dose Logs')
@Controller('dose-logs')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class DoseLogsController {
  constructor(private doseLogsService: DoseLogsService) {}

  @Post()
  @ApiOperation({ summary: 'Log a dose' })
  @ApiResponse({ status: 201, description: 'Dose logged successfully' })
  async create(@Request() req: any, @Body() dto: CreateDoseLogDto): Promise<DoseLogResponseDto> {
    return this.doseLogsService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get dose logs with filters' })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
  @ApiQuery({ name: 'medicationId', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiResponse({ status: 200, description: 'Dose logs retrieved successfully' })
  async findAll(
    @Request() req: any,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('medicationId') medicationId?: string,
    @Query('status') status?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ): Promise<DoseLogResponseDto> {
    return this.doseLogsService.findAll(req.user.id, {
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      medicationId,
      status,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });
  }

  @Get('today')
  @ApiOperation({ summary: 'Get today\'s dose logs' })
  @ApiResponse({ status: 200, description: 'Today\'s dose logs retrieved' })
  async getTodayLogs(@Request() req: any): Promise<DoseLogResponseDto> {
    return this.doseLogsService.getTodayLogs(req.user.id);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get dose log history' })
  @ApiQuery({ name: 'days', required: false, example: 30 })
  @ApiResponse({ status: 200, description: 'Dose log history retrieved' })
  async getHistory(@Request() req: any, @Query('days') days?: number): Promise<DoseLogResponseDto> {
    return this.doseLogsService.getHistory(req.user.id, days || 30);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a dose log' })
  @ApiParam({ name: 'id', description: 'Dose log ID' })
  @ApiResponse({ status: 200, description: 'Dose log updated successfully' })
  @ApiResponse({ status: 404, description: 'Dose log not found' })
  async update(
    @Request() req: any,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateDoseLogDto,
  ): Promise<DoseLogResponseDto> {
    return this.doseLogsService.update(req.user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a dose log' })
  @ApiParam({ name: 'id', description: 'Dose log ID' })
  @ApiResponse({ status: 200, description: 'Dose log deleted successfully' })
  @ApiResponse({ status: 404, description: 'Dose log not found' })
  async delete(@Request() req: any, @Param('id', ParseUUIDPipe) id: string): Promise<{ success: boolean; message: string }> {
    return this.doseLogsService.delete(req.user.id, id);
  }

  @Get('stats/summary')
  @ApiOperation({ summary: 'Get dose log statistics' })
  @ApiQuery({ name: 'startDate', required: true })
  @ApiQuery({ name: 'endDate', required: true })
  @ApiResponse({ status: 200, description: 'Statistics retrieved' })
  async getStats(
    @Request() req: any,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    return this.doseLogsService.getStats(req.user.id, new Date(startDate), new Date(endDate));
  }
}