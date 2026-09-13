import 'package:drift/drift.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get message => text().withDefault(const Constant(''))();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get repeatType => text().withDefault(const Constant('none'))(); // none, daily, weekly, monthly
  TextColumn get priority => text().withDefault(const Constant('normal'))(); // low, normal, high
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, completed, snoozed
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
} 