from django.contrib import admin
from .models import Student, TimetableEntry

@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'regNumber', 'program', 'year', 'hasRfid', 'hasFingerprint']
    list_filter = ['program', 'year', 'hasRfid', 'hasFingerprint']
    search_fields = ['name', 'regNumber']

@admin.register(TimetableEntry)
class TimetableEntryAdmin(admin.ModelAdmin):
    list_display = ('program', 'course', 'teacher', 'day', 'startTime', 'endTime')
    list_filter = ('program', 'day', 'year')