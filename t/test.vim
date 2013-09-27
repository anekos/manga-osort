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
end
