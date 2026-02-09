from rest_framework import serializers
from .models import Student

class StudentSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Student
        fields = ['id', 'name', 'regNumber', 'program', 'year', 'hasRfid', 'hasFingerprint']

    def to_representation(self, instance):
        """Convert the reponse to match your Dart model's fromJson method."""
        representation = super().to_representation(instance)
        representation['id'] = str(representation['id'])  # Convert id to string
        representation['hasRfid'] = 1 if representation['hasRfid'] else 0  # Convert boolean to int
        representation['hasFingerprint'] = 1 if representation['hasFingerprint'] else 0
        return representation
    
    def to_internal_value(self, data):
        """Convert incoming data to match Django model"""
        if 'hasRfid' in data:
            data['hasRfid'] = bool(data['hasRfid']) if isinstance(data['hasRfid'], (int, str)) else data['hasRfid']
        if 'hasFingerprint' in data:
            data['hasFingerprint'] = bool(data['hasFingerprint']) if isinstance(data['hasFingerprint'], (int, str)) else data['hasFingerprint']
        return super().to_internal_value(data)