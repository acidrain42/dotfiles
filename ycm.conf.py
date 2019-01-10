import os


def Settings(**kwargs):
    prefix = os.environ.get('VIRTUAL_ENV', os.path.join('/usr', 'local'))
    return {
        'interpreter_path': os.path.join(prefix, 'bin', 'python')
    }
