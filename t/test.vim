call vspec#hint({'scope': 'manga_osort#scope()', 'sid': 'manga_osort#sid()'})

describe 'QParseArgs'
  it 'returns default options'
    Expect Call('s:FParseArgs', []) == Ref('s:default_options')
  end

  it 'parse args'
    Expect Call('s:FParseArgs', ['key=1']) == {'key': '1', 'ignorecase': 0, 'pre': 0, 'pattern': ''}
    Expect Call('s:FParseArgs', ['key=2']) == {'key': '2', 'ignorecase': 0, 'pre': 0, 'pattern': ''}

    Expect Call('s:FParseArgs', ['key=2', 'ignorecase=1']) == {'key': '2', 'ignorecase': '1', 'pre': 0, 'pattern': ''}

    Expect Call('s:FParseArgs', ['pre=2', 'ignorecase=1']) == {'key': 0, 'ignorecase': '1', 'pre': '2', 'pattern': ''}
  end

  it 'g:manga_osort_default_options overwrites default options'
    let g:manga_osort_default_options = {'key': 7}
    Expect Call('s:FParseArgs', []) == {'key': 7, 'ignorecase': 0, 'pre': 0, 'pattern': ''}

    let g:manga_osort_default_options = {'ignorecase': 42}
    Expect Call('s:FParseArgs', []) == {'key': 0, 'ignorecase': 42, 'pre': 0, 'pattern': ''}
  end

  it 'alias overwrites parameter and default'
    unlet g:manga_osort_default_options
    let g:manga_osort_alias = {'#x': {'pattern': 'meow'}, '#y': {'ignorecase': 616}}

    Expect Call('s:FParseArgs', []) == {'key': 0, 'ignorecase': 0, 'pre': 0, 'pattern': ''}
    Expect Call('s:FParseArgs', ['key=1', '#x']) == {'key': '1', 'ignorecase': 0, 'pre': 0, 'pattern': 'meow'}
    Expect Call('s:FParseArgs', ['key=1', 'foo', '#x']) == {'key': '1', 'ignorecase': 0, 'pre': 0, 'pattern': 'meow'}
    Expect Call('s:FParseArgs', ['key=1', '#x', 'foo']) == {'key': '1', 'ignorecase': 0, 'pre': 0, 'pattern': 'foo'}

    let g:manga_osort_default_options = {'ignorecase': 42}
    Expect Call('s:FParseArgs', ['ignorecase=666']) == {'key': 0, 'ignorecase': '666', 'pre': 0, 'pattern': ''}
    Expect Call('s:FParseArgs', ['#y']) == {'key': 0, 'ignorecase': 616, 'pre': 0, 'pattern': ''}
  end
end
