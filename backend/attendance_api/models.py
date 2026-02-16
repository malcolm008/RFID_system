from django.core.exceptions import ValidationError
from django.db import models

def validate_integer(value):
    if not isinstance(value, int):
        raise ValidationError('Duratioin must be an integer')


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

class Device(models.Model):
    class DeviceType(models.TextChoices):
        RFID = 'rfid', 'RFID'
        FINGERPRINT = 'fingerprint', 'Fingerprint'
        HYBRID = 'hybrid', 'Hybrid'

    class DeviceStatus(models.TextChoices):
        ONLINE = 'online', 'Online'
        OFFLINE = 'offline', 'Offline'

    name = models.CharField(max_length=100)
    type = models.CharField(
        max_length=20,
        choices=DeviceType.choices
    )
    location = models.CharField(max_length=150)
    lastSeen = models.DateTimeField()
    status = models.CharField(
        max_length=20,
        choices=DeviceStatus.choices,
        default=DeviceStatus.OFFLINE
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.type})"

class Program(models.Model):
    QUALIFICATION_CHOICES = [
        ('Certificate', 'Certificate'),
        ('Diploma', 'Diploma'),
        ('Degree', 'Degree'),
        ('Masters', 'Masters'),
        ('PhD', 'PhD'),
    ]

    LEVEL_CHOICES = [
        ('undergraduate', 'Undergraduate'),
        ('postgraduate', 'Postgraduate'),
    ]

    name = models.CharField(max_length=100)
    qualification = models.CharField(
        max_length=20,
        choices=QUALIFICATION_CHOICES,
        default='Certificate',
    )
    level = models.CharField(
        max_length=20,
        choices=LEVEL_CHOICES,
        null=True,
        blank=True
    )
    duration = models.IntegerField(validators=[validate_integer])
    department = models.CharField(max_length=100)

    def __str__(self):
        return f"{self.name} ({self.qualification})"

class Course(models.Model):
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=50)

    qualification = models.CharField(
        max_length=20,
        choices=Program.QUALIFICATION_CHOICES
    )

    programs = models.ManyToManyField(
        Program,
        related_name = "courses"
    )

    semester = models.IntegerField()
    year = models.IntegerField()

    def __str__(self):
        return self.name


