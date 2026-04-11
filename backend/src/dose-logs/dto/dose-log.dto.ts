import { IsString, IsOptional, IsEnum, IsDateString, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum IntakeStatus {
  PENDING = 'PENDING',
  TAKEN = 'TAKEN',
  MISSED = 'MISSED',
  SNOOZED = 'SNOOZED',
}

export class CreateDoseLogDto {
  @ApiProperty()
  @IsString()
  medicationId: string;

  @ApiProperty({ example: '2024-01-01T08:00:00Z' })
  @IsDateString()
  scheduledTime: string;

  @ApiPropertyOptional({ enum: IntakeStatus, example: 'PENDING' })
  @IsOptional()
  @IsEnum(IntakeStatus)
  intakeStatus?: IntakeStatus;

  @ApiPropertyOptional({ example: 'Taken with breakfast' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ example: 'Felt mild headache' })
  @IsOptional()
  @IsString()
  symptoms?: string;
}

export class UpdateDoseLogDto {
  @ApiPropertyOptional({ enum: IntakeStatus })
  @IsOptional()
  @IsEnum(IntakeStatus)
  intakeStatus?: IntakeStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  symptoms?: string;
}

export class DoseLogDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  userId: string;

  @ApiProperty()
  medicationId: string;

  @ApiProperty()
  scheduledTime: Date;

  @ApiPropertyOptional()
  takenTime?: Date;

  @ApiProperty({ enum: IntakeStatus })
  intakeStatus: IntakeStatus;

  @ApiPropertyOptional()
  notes?: string;

  @ApiPropertyOptional()
  symptoms?: string;

  @ApiPropertyOptional()
  medication?: {
    id: string;
    name: string;
    dosage: string;
    form: string;
  } | null;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

export class DoseLogResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiPropertyOptional({ type: DoseLogDto })
  data?: DoseLogDto | DoseLogDto[];

  @ApiPropertyOptional()
  message?: string;

  @ApiPropertyOptional()
  error?: string;
}

export class DoseLogStatsDto {
  @ApiProperty()
  total: number;

  @ApiProperty()
  taken: number;

  @ApiProperty()
  missed: number;

  @ApiProperty()
  snoozed: number;

  @ApiProperty()
  pending: number;

  @ApiProperty()
  adherenceRate: number;
}