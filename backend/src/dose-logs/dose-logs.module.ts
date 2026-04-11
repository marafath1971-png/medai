import { Module } from '@nestjs/common';
import { DoseLogsController } from './dose-logs.controller';
import { DoseLogsService } from './dose-logs.service';

@Module({
  controllers: [DoseLogsController],
  providers: [DoseLogsService],
  exports: [DoseLogsService],
})
export class DoseLogsModule {}