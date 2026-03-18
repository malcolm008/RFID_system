from django.core.management.base import BaseCommand
from attendance_api.models import User

class Command(BaseCommand)
    help = 'Created dummy users for testing'

    def handle(self, *args, **options):
        dummy_users = [
            {
                'name': 'Malcolm Mwaki',
                'email': 'mack.mwaki@test.com',
                'password': 'admin123',
                'role': 0,
                'department': 'IT',
                'position': 'System Administrator'
            },
            {
                'name': 'Jane Admin',
                'email': 'jane.admin@test.com',
                'password': 'admin123',
                'role': 1,
                'department': 'Administration',
                'position': 'Office Administrator'
            },
            {
                'name': 'John Manager',
                'email': 'john.manager@test.com',
                'password': 'manager123',
                'role': 2,
                'department': 'Operations',
                'position': 'Operations Manager'
            },
            {
                'name': 'Sarah Viewer',
                'email': 'sarah.viewer@test.com',
                'password': 'viewer123',
                'role': 3,  # Viewer
                'department': 'Sales',
                'position': 'Sales Representative'
            },
        ]

        created_count = 0
        existing_count = 0

        for user_data in dummy_users:
            if not User.objects.filter(email=user_data['email']).exists():
                user = User(
                    name=user_data['name'],
                    email=user_data['email'],
                    department=user_data.get('department', ''),
                    position=user_data.get('position', ''),
                    role=user_data['role'],
                    is_active=True
                )
                user.set_password(user_data['password'])
                user.save()
                created_count += 1
                self.stdout.write(
                    self.style.SUCCESS(f'✅ Created: {user_data["name"]} ({user_data["email"]})')
                )
            else:
                existing_count += 1
                self.stdout.write(
                    self.style.WARNING(f'Exists: {user_data["email"]}')
                )

                self.stdout.write(self.style.SUCCESS(f'\n✅ Created {created_count} new users'))
                self.stdout.write(self.style.WARNING(f'⚠️ {existing_count} users already exist'))