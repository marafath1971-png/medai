import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { MedicationsService } from './medications.service';
import { CreateMedicationDto, UpdateMedicationDto, MedicationResponseDto } from './dto/medication.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('Medications')
@Controller('medications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new medication' })
  @ApiResponse({ status: 201, description: 'Medication created successfully' })
  async create(@Request() req: any, @Body() dto: CreateMedicationDto): Promise<MedicationResponseDto> {
    return this.medicationsService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all medications for user' })
  @ApiResponse({ status: 200, description: 'Medications retrieved successfully' })
  async findAll(@Request() req: any): Promise<MedicationResponseDto> {
    return this.medicationsService.findAll(req.user.id);
  }

  @Get('low-stock')
  @ApiOperation({ summary: 'Get low stock medications' })
  @ApiResponse({ status: 200, description: 'Low stock medications retrieved' })
  async getLowStock(@Request() req: any): Promise<MedicationResponseDto> {
    return this.medicationsService.getLowStock(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a specific medication' })
  @ApiParam({ name: 'id', description: 'Medication ID' })
  @ApiResponse({ status: 200, description: 'Medication retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Medication not found' })
  async findOne(@Request() req: any, @Param('id', ParseUUIDPipe) id: string): Promise<MedicationResponseDto> {
    return this.medicationsService.findOne(req.user.id, id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a medication' })
  @ApiParam({ name: 'id', description: 'Medication ID' })
  @ApiResponse({ status: 200, description: 'Medication updated successfully' })
  @ApiResponse({ status: 404, description: 'Medication not found' })
  async update(
    @Request() req: any,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateMedicationDto,
  ): Promise<MedicationResponseDto> {
    return this.medicationsService.update(req.user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a medication' })
  @ApiParam({ name: 'id', description: 'Medication ID' })
  @ApiResponse({ status: 200, description: 'Medication deleted successfully' })
  @ApiResponse({ status: 404, description: 'Medication not found' })
  async delete(@Request() req: any, @Param('id', ParseUUIDPipe) id: string): Promise<{ success: boolean; message: string }> {
    return this.medicationsService.delete(req.user.id, id);
  }

  @Put(':id/count')
  @ApiOperation({ summary: 'Update pill count' })
  @ApiParam({ name: 'id', description: 'Medication ID' })
  @ApiResponse({ status: 200, description: 'Pill count updated successfully' })
  async updatePillCount(
    @Request() req: any,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: { pillCount: number },
  ): Promise<MedicationResponseDto> {
    return this.medicationsService.updatePillCount(req.user.id, id, dto.pillCount);
  }

  @Post('scan')
  @ApiOperation({ summary: 'Scan prescription image' })
  @ApiResponse({ status: 200, description: 'Prescription scanned successfully' })
  async scanPrescription(@Request() req: any): Promise<{ success: boolean; data?: any; message?: string }> {
    // In a real implementation, you'd handle file upload and AI processing
    return {
      success: true,
      message: 'Prescription scanning simulated',
      data: {
        name: 'Sample Medication',
        dosage: '500mg',
        frequency: 'Once daily',
        instructions: 'Take with food',
        confidence: 0.95,
      },
    };
  }
}