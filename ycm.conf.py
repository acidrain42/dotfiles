import os


def Settings(**kwargs):
    prefix = os.environ.get('VIRTUAL_ENV', '/usr')
    return {
        'interpreter_path': os.path.join(prefix, 'bin', 'python')
    }
