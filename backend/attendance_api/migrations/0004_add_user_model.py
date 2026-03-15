from django.db import migrations, models
from django.contrib.auth.hashers import make_password
import uuid

def create_dummy_superadmin(apps, schema_editor):
    User = apps.get_model('attendance_api', 'User')

    # Create dummy superadmin user
    User.objects.create(
        id=str(uuid.uuid4()),
        name='Malcolm Mwaki',
        email='mack.mwaki@test.com',
        password=make_password('admin123'),  # Hash the password
        phone='+1234567890',
        department='IT Administration',
        position='System Administrator',
        role=0,  # Super Administrator
        is_active=True,
        permissions={
            'can_manage_admins': True,
            'can_manage_users': True,
            'can_manage_content': True,
            'can_view_reports': True
        }
    )

def reverse_func(apps, schema_editor):
    User = apps.get_model('attendance_api', 'User')
    User.objects.filter(email='mack.mwaki@test.com').delete()

class Migration(migrations.Migration):
    dependencies = [
        ('attendance_api', 'XXXX_previous_migration'),  # Replace with your last migration
    ]

    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.CharField(max_length=100, primary_key=True, default=uuid.uuid4, editable=False)),
                ('name', models.CharField(max_length=200)),
                ('email', models.EmailField(unique=True)),
                ('password', models.CharField(max_length=255)),
                ('phone', models.CharField(blank=True, max_length=20, null=True)),
                ('department', models.CharField(blank=True, max_length=100, null=True)),
                ('position', models.CharField(blank=True, max_length=100, null=True)),
                ('role', models.IntegerField(choices=[(0, 'Super Administrator'), (1, 'Administrator'), (2, 'Manager'), (3, 'Viewer')], default=3)),
                ('is_active', models.BooleanField(default=True)),
                ('profile_image_url', models.URLField(blank=True, null=True)),
                ('permissions', models.JSONField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('last_login', models.DateTimeField(blank=True, null=True)),
            ],
            options={
                'db_table': 'users',
                'ordering': ['-created_at'],
            },
        ),
        migrations.RunPython(create_dummy_superadmin, reverse_func),
    ]