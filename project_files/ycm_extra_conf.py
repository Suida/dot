def Settings(**kwargs):
    lang = kwargs['language']

    if lang == 'cfamily':
        return {
            'flags': ['-Wall', '-Wextra', '-Werror'],
        }

    if lang == 'vue':
        return {
            'ls': {
                'vetur': {
                    'useWorkspaceDependencies': False,
                    'validation': {
                        'template': True,
                        'style': True,
                        'script': True,
                    },
                    'completion': {
                        'autoImport': True,
                        'useScaffoldSnippets': False,
                        'tagCasing': 'initial',
                        'scaffoldSnippetSources': {
                            'workspace': '💼',
                            'user': '🗒️',
                            'vetur': '✌',
                        },
                    },
                    'grammar': {'customBlocks': {}},
                    'format': {
                        'enable': True,
                        'options': {'tabSize': 2, 'useTabs': False},
                        'defaultFormatter': {
                            'js': 'prettier',
                            'ts': 'prettier',
                        },
                        'defaultFormatterOptions': {},
                        'scriptInitialIndent': False,
                        'styleInitialIndent': False,
                    },
                    'trace': {'server': 'off'},
                    'dev': {'vlsPath': '', 'vlsPort': -1, 'logLevel': 'INFO'},
                    'experimental': {'templateInterpolationService': False},
                },
            },
        }

    return {}
