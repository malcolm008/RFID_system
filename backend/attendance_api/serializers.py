from rest_framework import serializers
from .models import Student, Teacher, Device, Program, Course

class StudentSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)  # To match your Dart model's string id

    class Meta:
        model = Student
        fields = ['id', 'name', 'regNumber', 'program', 'year', 'hasRfid', 'hasFingerprint']

    def to_representation(self, instance):
        """Convert the response to match your Dart model's fromJson method"""
        representation = super().to_representation(instance)
        # Convert id to string if needed (Dart expects string)
        representation['id'] = str(representation['id'])
        # Convert booleans to 1/0 if needed (your Dart code accepts both)
        representation['hasRfid'] = 1 if representation['hasRfid'] else 0
        representation['hasFingerprint'] = 1 if representation['hasFingerprint'] else 0
        return representation

    def to_internal_value(self, data):
        """Convert incoming data to match Django model"""
        # Convert 1/0 to booleans if sent from Dart
        if 'hasRfid' in data:
            data['hasRfid'] = bool(data['hasRfid']) if isinstance(data['hasRfid'], (int, str)) else data['hasRfid']
        if 'hasFingerprint' in data:
            data['hasFingerprint'] = bool(data['hasFingerprint']) if isinstance(data['hasFingerprint'], (int, str)) else data['hasFingerprint']
        return super().to_internal_value(data)

class TeacherSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)

    class Meta:
        model = Teacher
        fields = ['id', 'name', 'email', 'course', 'department', 'hasRfid', 'hasFingerprint']

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['id'] = str(representation['id'])
        representation['hasRfid'] = 1 if representation['hasRfid'] else 0
        representation['hasFingerprint'] = 1 if representation['hasFingerprint'] else 0
        return representation

    def to_internal_value(self, data):
        if 'hasRfid' in data:
            data['hasRfid'] = bool(data['hasRfid']) if isinstance(data['hasRfid'], (int, str)) else data['hasRfid']
        if 'hasFingerprint' in data:
            data['hasFingerprint'] = bool(data['hasFingerprint']) if isinstance(data['hasFingerprint'], (int, str)) else data['hasFingerprint']
        return super().to_internal_value(data)


class DeviceSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)

    class Meta:
        model = Device
        fields = ['id', 'name', 'type', 'location', 'lastSeen', 'status',]

        def to_representation(self, instance):
            rep = super().to_representation(instance)
            rep['id'] = str(rep['id'])
            return rep

class ProgramSerializer(serializers.ModelSerializer):
    class Meta:
        model = Program
        fields = '__all__'

    def validate(self, data):
        qualification = data.get('qualification')
        level = data.get('level')

        if qualification == 'Degree' and not level:
            raise serializers.ValidationError(
                {"level": "Degree programs require a level"}
            )

        if qualification in ['Certificate', 'Diploma'] and level:
            raise serializers.ValidationError(
                {"level": "This qualification does not support levels"}
            )

        return data

class CourseSerializer(serializers.ModelSerializer):
    program_name = serializers.CharField(
        source='program.name',
        read_only=True
    )

    class Meta:
        model = Course
        fields = '__all__'

    def validate(self, data):
        program = data.get('program')
        qualification = data.get('qualification')
        year = data.get('year')

        if program.qualification != qualification:
            raise serializers.ValidationError(
                "Selected program does not belong to selected qualification."
            )

        if year > program.duration:
            raise serializers.ValidationError(
                f"Year cannot exceed program duration ({program.duration})."
            )

        return data