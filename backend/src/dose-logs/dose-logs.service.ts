import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDoseLogDto, UpdateDoseLogDto, DoseLogResponseDto } from './dto/dose-log.dto';

@Injectable()
export class DoseLogsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateDoseLogDto): Promise<DoseLogResponseDto> {
    const medication = await this.prisma.medication.findFirst({
      where: { id: dto.medicationId, userId },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    const doseLog = await this.prisma.doseLog.create({
      data: {
        userId,
        medicationId: dto.medicationId,
        scheduledTime: new Date(dto.scheduledTime),
        takenTime: dto.intakeStatus === 'TAKEN' ? new Date() : null,
        intakeStatus: dto.intakeStatus || 'PENDING',
        notes: dto.notes,
        symptoms: dto.symptoms,
      },
      include: { medication: true },
    });

    return {
      success: true,
      data: this.formatDoseLog(doseLog),
    };
  }

  async findAll(userId: string, filters?: { startDate?: Date; endDate?: Date; medicationId?: string; status?: string; page?: number; limit?: number }): Promise<DoseLogResponseDto> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = { userId };
    if (filters?.startDate) where.scheduledTime = { ...where.scheduledTime, gte: filters.startDate };
    if (filters?.endDate) where.scheduledTime = { ...where.scheduledTime, lte: filters.endDate };
    if (filters?.medicationId) where.medicationId = filters.medicationId;
    if (filters?.status) where.intakeStatus = filters.status;

    const [logs, total] = await Promise.all([
      this.prisma.doseLog.findMany({
        where,
        include: { medication: true },
        orderBy: { scheduledTime: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.doseLog.count({ where }),
    ]);

    return {
      success: true,
      data: logs.map(l => this.formatDoseLog(l)),
    };
  }

  async getTodayLogs(userId: string): Promise<DoseLogResponseDto> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const logs = await this.prisma.doseLog.findMany({
      where: {
        userId,
        scheduledTime: {
          gte: today,
          lt: tomorrow,
        },
      },
      include: { medication: true },
      orderBy: { scheduledTime: 'asc' },
    });

    return {
      success: true,
      data: logs.map(l => this.formatDoseLog(l)),
    };
  }

  async getHistory(userId: string, days: number = 30): Promise<DoseLogResponseDto> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const logs = await this.prisma.doseLog.findMany({
      where: {
        userId,
        scheduledTime: { gte: startDate },
      },
      include: { medication: true },
      orderBy: { scheduledTime: 'desc' },
    });

    return {
      success: true,
      data: logs.map(l => this.formatDoseLog(l)),
    };
  }

  async update(userId: string, id: string, dto: UpdateDoseLogDto): Promise<DoseLogResponseDto> {
    const existing = await this.prisma.doseLog.findFirst({
      where: { id, userId },
    });

    if (!existing) {
      throw new NotFoundException('Dose log not found');
    }

    const updateData: any = {};
    if (dto.intakeStatus) {
      updateData.intakeStatus = dto.intakeStatus;
      if (dto.intakeStatus === 'TAKEN') {
        updateData.takenTime = new Date();
      }
    }
    if (dto.notes !== undefined) updateData.notes = dto.notes;
    if (dto.symptoms !== undefined) updateData.symptoms = dto.symptoms;

    const doseLog = await this.prisma.doseLog.update({
      where: { id },
      data: updateData,
      include: { medication: true },
    });

    return {
      success: true,
      data: this.formatDoseLog(doseLog),
    };
  }

  async delete(userId: string, id: string): Promise<{ success: boolean; message: string }> {
    const existing = await this.prisma.doseLog.findFirst({
      where: { id, userId },
    });

    if (!existing) {
      throw new NotFoundException('Dose log not found');
    }

    await this.prisma.doseLog.delete({ where: { id } });

    return { success: true, message: 'Dose log deleted successfully' };
  }

  async getStats(userId: string, startDate: Date, endDate: Date) {
    const logs = await this.prisma.doseLog.findMany({
      where: {
        userId,
        scheduledTime: { gte: startDate, lte: endDate },
      },
    });

    const stats = {
      total: logs.length,
      taken: logs.filter(l => l.intakeStatus === 'TAKEN').length,
      missed: logs.filter(l => l.intakeStatus === 'MISSED').length,
      snoozed: logs.filter(l => l.intakeStatus === 'SNOOZED').length,
      pending: logs.filter(l => l.intakeStatus === 'PENDING').length,
    };

    return {
      success: true,
      data: {
        ...stats,
        adherenceRate: stats.total > 0 ? (stats.taken / stats.total) * 100 : 0,
      },
    };
  }

  private formatDoseLog(log: any) {
    return {
      id: log.id,
      userId: log.userId,
      medicationId: log.medicationId,
      scheduledTime: log.scheduledTime,
      takenTime: log.takenTime,
      intakeStatus: log.intakeStatus,
      notes: log.notes,
      symptoms: log.symptoms,
      medication: log.medication ? {
        id: log.medication.id,
        name: log.medication.name,
        dosage: log.medication.dosage,
        form: log.medication.form,
      } : null,
      createdAt: log.createdAt,
      updatedAt: log.updatedAt,
    };
  }
}