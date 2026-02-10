from django.contrib import admin
from .models import Student

@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'regNumber', 'program', 'year', 'hasRfid', 'hasFingerprint']
    list_filter = ['program', 'year', 'hasRfid', 'hasFingerprint']
    search_fields = ['name', 'regNumber']