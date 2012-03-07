from tardis.settings_changeme import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'mytardis',
        'USER': 'mytardis',
        'PASSWORD': 'mytardis', # unused with ident auth
        'HOST': '',
        'PORT': '',
    }
}

# Disable faulty equipment app
INSTALLED_APPS = filter(lambda a: a != 'tardis.apps.equipment', INSTALLED_APPS)

