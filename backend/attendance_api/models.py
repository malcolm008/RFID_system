from django.core.exceptions import ValidationError
from django.db import models
from django.contrib.auth.hashers import make_password, check_password
import uuid

def validate_integer(value):
    if not isinstance(value, int):
        raise ValidationError('Duratioin must be an integer')


class User(models.Model):
    USER_ROLES = [
        (0, 'Super Administrator'),
        (1, 'Administrator'),
        (2, 'Manager'),
        (3, 'Viewer'),
    ]

    id = models.CharField(max_length=100, primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)  # Will store hashed password
    phone = models.CharField(max_length=20, null=True, blank=True)
    department = models.CharField(max_length=100, null=True, blank=True)
    position = models.CharField(max_length=100, null=True, blank=True)
    role = models.IntegerField(choices=USER_ROLES, default=3)  # Default to Viewer
    is_active = models.BooleanField(default=True)
    profile_image_url = models.URLField(null=True, blank=True)
    permissions = models.JSONField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.name} ({self.email})"

    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password)

    def get_role_display_name(self):
        return dict(self.USER_ROLES).get(self.role, 'Unknown')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'department': self.department,
            'position': self.position,
            'role': self.role,
            'role_display': self.get_role_display_name(),
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat(),
            'last_login': self.last_login.isoformat() if self.last_login else None,
            'profile_image_url': self.profile_image_url,
        }

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']


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
    lastSeen = models.DateTimeField(auto_now=True)
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
    abbreviation = models.CharField(
        max_length=20,
        unique=True,
    )
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
        return self.abbreviation

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


class TimetableEntry(models.Model):
    DAY_CHOICES = [
        ('Monday', 'Monday'),
        ('Tuesday', 'Tuesday'),
        ('Wednesday', 'Wednesday'),
        ('Thursday', 'Thursday'),
        ('Friday', 'Friday'),
        ('Saturday', 'Saturday'),
        ('Sunday', 'Sunday'),
    ]
    program = models.ForeignKey(
        'Program',
        on_delete=models.CASCADE,
        related_name='timetable_entries'
    )
    course = models.ForeignKey(
        'Course',
        on_delete=models.CASCADE,
        related_name='timetable_entries'
    )
    teacher = models.ForeignKey(
        'Teacher',
        on_delete=models.SET_NULL,
        null = True,
        blank = True,
        related_name='timetable_entries'
    )
    device = models.ForeignKey(
        'Device',
        on_delete=models.SET_NULL,
        null= True,
        blank=True,
        related_name='timetable_entries'
    )
    location = models.CharField(max_length=200)
    year = models.IntegerField()
    day = models.CharField(max_length=10, choices=DAY_CHOICES)
    startTime = models.TimeField()
    endTime = models.TimeField()
    qualification = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.program} - {self.course} ({self.day} {self.start_time})"