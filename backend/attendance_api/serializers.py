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
    duration = serializers.IntegerField(
        error_messages ={
            'invalid': 'Duration must be an integer (number of years)'
        }
    )

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
    program_abbreviations = serializers.SerializerMethodField()

    class Meta:
        model = Course
        fields = '__all__'

    def get_program_abbreviations(self, obj):
        return [program.abbreviation for program in obj.programs.all()]

    def validate(self, data):
        program_ids = data.get('programs')
        qualification = data.get('qualification')
        year = data.get('year')

        if not program_ids:
            raise serializers.ValidationError("At least one program must be selected.")

        programs = Program.objects.filter(id__in=program_ids)
        for program in programs:
            if program.qualification != qualification:
                raise serializers.ValidationError(
                    f"{program.name} does not belong to {qualification}."
                )
            if year > program.duration:
                raise serializers.ValidationError(
                    f"Year cannot exceed duration of {program.name} ({program.duration})."
                )

        # Replace IDs with actual program instances
        data['programs'] = programs
        return data

    def create(self, validated_data):
        programs = validated_data.pop('programs')
        course = Course.objects.create(**validated_data)
        course.programs.set(programs)
        return course

    def update(self, instance, validated_data):
        programs = validated_data.pop('programs', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if programs is not None:
            instance.programs.set(programs)
        return instance
