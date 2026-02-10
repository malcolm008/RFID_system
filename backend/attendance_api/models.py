from django.db import models

class Student(models.Model):
    name = models.CharField(max_length=200)
    regNumber = models.CharField(max_length=50, unique=True)  # Note the capital N to match your Dart code
    program = models.CharField(max_length=100)
    year = models.IntegerField()
    hasRfid = models.BooleanField(default=False)
    hasFingerprint = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.regNumber})"

class Teacher(models.Model):
    name = models.CharField(max_length=200)
    email = models.CharField(max_length=200, unique=True)
    course = models.CharField(max_length=100)
    department = models.CharField(max_length=100)
    hasRfid = models.BooleanField(default=False)
    hasFingerprint = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.email})"