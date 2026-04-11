import { IsString, IsNumber, IsOptional, IsEnum, IsDateString, IsBoolean, IsArray, ValidateNested, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum DoseForm {
  TABLET = 'TABLET',
  CAPSULE = 'CAPSULE',
  LIQUID = 'LIQUID',
  INJECTION = 'INJECTION',
  TOPICAL = 'TOPICAL',
  INHALER = 'INHALER',
  OTHER = 'OTHER',
}

export class CreateMedicationDto {
  @ApiProperty({ example: 'Metformin' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Metformin HCL' })
  @IsOptional()
  @IsString()
  genericName?: string;

  @ApiProperty({ example: '500mg' })
  @IsString()
  dosage: string;

  @ApiPropertyOptional({ enum: DoseForm, example: 'TABLET' })
  @IsOptional()
  @IsEnum(DoseForm)
  form?: DoseForm;

  @ApiProperty({ example: 'Twice daily with meals' })
  @IsString()
  frequency: string;

  @ApiPropertyOptional({ example: 30 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  pillCount?: number;

  @ApiPropertyOptional({ example: 7 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  refillThreshold?: number;

  @ApiPropertyOptional({ example: 'Take with food' })
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiPropertyOptional({ example: '2024-01-01' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ example: '2024-12-31' })
  @IsOptional()
  @IsDateString()
  endDate?: string;
}

export class UpdateMedicationDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  genericName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  dosage?: string;

  @ApiPropertyOptional({ enum: DoseForm })
  @IsOptional()
  @IsEnum(DoseForm)
  form?: DoseForm;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  frequency?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  pillCount?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  refillThreshold?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class MedicationDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  userId: string;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  genericName?: string;

  @ApiProperty()
  dosage: string;

  @ApiProperty({ enum: DoseForm })
  form: DoseForm;

  @ApiProperty()
  frequency: string;

  @ApiProperty()
  pillCount: number;

  @ApiProperty()
  refillThreshold: number;

  @ApiPropertyOptional()
  instructions?: string;

  @ApiProperty()
  startDate: Date;

  @ApiPropertyOptional()
  endDate?: Date;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

export class MedicationResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiPropertyOptional({ type: MedicationDto })
  data?: MedicationDto | MedicationDto[];

  @ApiPropertyOptional()
  message?: string;

  @ApiPropertyOptional()
  error?: string;
}