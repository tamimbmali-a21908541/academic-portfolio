from django.contrib.auth import get_user_model
from django.test import TestCase

from accounts.models import Profile


class TesteModelProfile(TestCase):
    def test_profile_criado_automaticamente_via_signal(self):
        User = get_user_model()
        user = User.objects.create_user(username="zezinho", password="pw")
        # signals.py cria sempre um Profile no post_save de User
        self.assertTrue(Profile.objects.filter(user=user).exists())

    def test_profile_str_inclui_username(self):
        User = get_user_model()
        user = User.objects.create_user(username="zezinho", password="pw")
        profile = user.profile
        self.assertIn("zezinho", str(profile))

    def test_profile_one_to_one_user(self):
        User = get_user_model()
        user = User.objects.create_user(username="ana", password="pw")
        # criar um segundo Profile para o mesmo user deve falhar (OneToOne)
        with self.assertRaises(Exception):
            Profile.objects.create(user=user)
