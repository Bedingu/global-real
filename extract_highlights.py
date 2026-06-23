import fitz

pdfs = {
    'Domingos de Morais': 'Empreendimentos/VITACON_DOMINGOS_MORAIS.pdf',
    'Joao Moura': 'Empreendimentos/VITACON_JOAO_MOURA.pdf',
    'Pinheiros': 'Empreendimentos/VITACON_PINHEIROS.pdf',
}

for name, path in pdfs.items():
    doc = fitz.open(path)
    pages = len(doc)
    text = ''
    for i in range(min(15, pages)):
        text += doc[i].get_text() + '\n'
    doc.close()
    
    lines = [l.strip() for l in text.split('\n') if l.strip() and len(l.strip()) > 15]
    print(f'\n=== {name} ({pages} pags) ===')
    for l in lines[:50]:
        print(f'  {l}')
