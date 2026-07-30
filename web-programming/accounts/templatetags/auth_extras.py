from django import template


register = template.Library()


@register.filter
def has_group(user, group_name):
    if not getattr(user, "is_authenticated", False):
        return False
    return user.is_superuser or user.groups.filter(name=group_name).exists()
