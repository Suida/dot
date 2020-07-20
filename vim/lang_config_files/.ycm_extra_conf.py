def Settings(**kwargs):
    lang = kwargs['language']
    if lang == 'cfamily':
        return {
            'flags': ['-Wall', '-Wextra', '-Werror'],
        }
    return {}
