import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
AUTH IMPORT PLACEHOLDER

import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe());
  AUTH BOOTSTRAP PLACEHOLDER
  await app.listen(8080);
}
bootstrap();
