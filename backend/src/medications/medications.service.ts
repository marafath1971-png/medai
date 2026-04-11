import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMedicationDto, UpdateMedicationDto, MedicationResponseDto } from './dto/medication.dto';

@Injectable()
export class MedicationsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateMedicationDto): Promise<MedicationResponseDto> {
    const medication = await this.prisma.medication.create({
      data: {
        userId,
        name: dto.name,
        genericName: dto.genericName,
        dosage: dto.dosage,
        form: dto.form || 'TABLET',
        frequency: dto.frequency,
        pillCount: dto.pillCount || 0,
        refillThreshold: dto.refillThreshold || 7,
        instructions: dto.instructions,
        startDate: new Date(dto.startDate || new Date()),
        endDate: dto.endDate ? new Date(dto.endDate) : null,
      },
      include: { user: false },
    });

    return {
      success: true,
      data: this.formatMedication(medication),
    };
  }

  async findAll(userId: string): Promise<MedicationResponseDto> {
    const medications = await this.prisma.medication.findMany({
      where: { userId, isActive: true },
      orderBy: { createdAt: 'desc' },
    });

    return {
      success: true,
      data: medications.map(m => this.formatMedication(m)),
    };
  }

  async findOne(userId: string, id: string): Promise<MedicationResponseDto> {
    const medication = await this.prisma.medication.findFirst({
      where: { id, userId },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    return {
      success: true,
      data: this.formatMedication(medication),
    };
  }

  async update(userId: string, id: string, dto: UpdateMedicationDto): Promise<MedicationResponseDto> {
    const existing = await this.prisma.medication.findFirst({
      where: { id, userId },
    });

    if (!existing) {
      throw new NotFoundException('Medication not found');
    }

    const medication = await this.prisma.medication.update({
      where: { id },
      data: {
        ...(dto.name && { name: dto.name }),
        ...(dto.genericName !== undefined && { genericName: dto.genericName }),
        ...(dto.dosage && { dosage: dto.dosage }),
        ...(dto.form && { form: dto.form }),
        ...(dto.frequency && { frequency: dto.frequency }),
        ...(dto.pillCount !== undefined && { pillCount: dto.pillCount }),
        ...(dto.refillThreshold !== undefined && { refillThreshold: dto.refillThreshold }),
        ...(dto.instructions !== undefined && { instructions: dto.instructions }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
    });

    return {
      success: true,
      data: this.formatMedication(medication),
    };
  }

  async delete(userId: string, id: string): Promise<{ success: boolean; message: string }> {
    const existing = await this.prisma.medication.findFirst({
      where: { id, userId },
    });

    if (!existing) {
      throw new NotFoundException('Medication not found');
    }

    await this.prisma.medication.delete({ where: { id } });

    return { success: true, message: 'Medication deleted successfully' };
  }

  async updatePillCount(userId: string, id: string, count: number): Promise<MedicationResponseDto> {
    const medication = await this.prisma.medication.findFirst({
      where: { id, userId },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    const updated = await this.prisma.medication.update({
      where: { id },
      data: { pillCount: count },
    });

    return {
      success: true,
      data: this.formatMedication(updated),
    };
  }

  async getLowStock(userId: string): Promise<MedicationResponseDto> {
    const medications = await this.prisma.medication.findMany({
      where: {
        userId,
        isActive: true,
      },
    });

    const lowStock = medications.filter(m => m.pillCount <= m.refillThreshold);

    return {
      success: true,
      data: lowStock.map(m => this.formatMedication(m)),
    };
  }

  private formatMedication(medication: any) {
    return {
      id: medication.id,
      userId: medication.userId,
      name: medication.name,
      genericName: medication.genericName,
      dosage: medication.dosage,
      form: medication.form,
      frequency: medication.frequency,
      pillCount: medication.pillCount,
      refillThreshold: medication.refillThreshold,
      instructions: medication.instructions,
      startDate: medication.startDate,
      endDate: medication.endDate,
      isActive: medication.isActive,
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
    };
  }
}