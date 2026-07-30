from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import Group

from .models import Profile


class LoginForm(forms.Form):
    username = forms.CharField(label="Username")
    password = forms.CharField(label="Password", widget=forms.PasswordInput)


class BaseUserCreationForm(UserCreationForm):
    email = forms.EmailField(required=True)

    class Meta(UserCreationForm.Meta):
        fields = ("username", "email", "password1", "password2")

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data["email"]
        if commit:
            user.save()
            autores, _ = Group.objects.get_or_create(name="autores")
            user.groups.add(autores)
            Profile.objects.get_or_create(user=user)
        return user
