from django.core.management import BaseCommand
from attendance_api.models import User

class Command(BaseCommand):
    help = 'Creates a superadmin for testing'

    def add_arguments(self, parser):
        parser.add_argument('--email', type=str, default='mack.mwaki@test.com')
        parser.add_argument('--password', type=str, default='admin123')
        parser.add_argument('--name', type=str, default='Malcolm Mwaki')

    def handle(self, *args, **options):
        email = options['email']
        password = options['password']
        name = options['name']

        if User.objects.filter(email=email).exists():
            self.stdout.write(
                self.style.WARNING(f'User {email} already exists')
            )
            user = User.objects.get(email=email)
            self.stdout.write(f"Name: {user.name}")
            self.stdout.write(f"Role: {user.get_role_display_name()}")
            return

        user = User(
            name=name,
            email=email,
            phone='+1234567890',
            department='IT Administration',
            position='System Administrator',
            role=0,  # Super Administrator
            is_active=True,
            permissions={
                'can_manage_admins': True,
                'can_manage_users': True,
                'can_manage_content': True,
                'can_view_reports': True,
                'can_manage_system': True
            }
        )
        user.set_password(password)
        user.save()

        self.stdout.write(
            self.style.SUCCESS(f'Superadmin created successfully')
        )
        self.stdout.write(f'Email: {email}')
        self.stdout.write(f'Password: {password}')
        self.stdout.write(f'Role: {user.get_role_display_name}')

