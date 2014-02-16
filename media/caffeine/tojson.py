import sys
import json
import datetime
from collections import namedtuple, defaultdict
import re


Coffee = namedtuple('Coffee', 'dt desc')
SHOPS = [
    'Herkimer',
    'Trabant',
    'Neptune',
]
OTHER_SEATTLE_SHOPS = [
    'Caffe Fiore',
    'Caffe Ladro',
    'Makeda',
    'Milstead',
    'Diva',
    'Uptown',
    'Green Bean',
    'Commons',  # Microsoft
    'Armory',  # Seattle Center
    'Sip and Ship',
    'Solstice',
]


def classify(desc):
    """Get a category string given a coffee description.
    """
    if 'at home' in desc or 'Distant Lands' in desc:
        return 'home'
    elif re.search(r'Seven (Brazil|coffee|Ethiopia)', desc):
        return 'work'
    elif re.search(r'Seven (Mexico)', desc):
        return 'home'
    elif "Tony's" in desc:
        return 'home'
    elif re.search(r'\dg (coffee|water)', desc):
        return 'home'
    elif re.search(r'Herkimer (Honduras|Guatemala|El Salvador)', desc):
        return 'work'
    elif 'conference' in desc.lower() or 'hotel' in desc.lower():
        return 'travel'
    elif re.search(r', (LA|San Diego|MI|Sunnyvale|London|CA)$', desc):
        return 'travel'
    elif desc.endswith(' CA') or ', CA' in desc or 'Pacahamama' in desc:
        return 'travel'
    elif 'Cambridge' in desc:
        return 'travel'
    elif re.search(r'in (SAN)$', desc):
        return 'travel'
    elif 'Sea-Tac' in desc:
        return 'travel'
    elif 'wedding' in desc.lower() or 'cupertino' in desc.lower():
        return 'travel'
    elif 'cse latte' in desc.lower():
        return 'espresso room'
    elif re.search(r'\b[A-Z][a-z]+\'s', desc):
        return 'friend'
    else:
        for shop in SHOPS:
            if shop.lower() in desc.lower():
                return shop
        for shop in OTHER_SEATTLE_SHOPS:
            if shop.lower() in desc.lower():
                return 'other Seattle caf\xe9'
        return 'other'


def dump_json(note_fn):
    # Read coffees.
    coffees = []
    with open(note_fn) as f:
        for line in f:
            timestamp, desc = line.strip().split(None, 1)
            dt = datetime.datetime.strptime(timestamp, '%Y-%m-%d-%H-%M-%S')
            coffees.append(Coffee(dt, desc))

    # Bucket the coffees by day.
    by_date = defaultdict(list)
    for coffee in coffees:
        by_date[coffee.dt.date()].append(coffee)

    # Emit a row for every date in the range. This captures those dates
    # with zero coffees.
    days = []
    cur_date = min(by_date.keys())
    end_date = max(by_date.keys())
    while cur_date <= end_date:
        days.append({
            'date': str(cur_date),
            'count': len(by_date[cur_date]),
        })
        cur_date += datetime.timedelta(days=1)

    # Dump the individual coffees and their attributes.
    flat_coffees = []
    for coffee in coffees:
        flat_coffees.append({
            'datetime': str(coffee.dt),
            'date': str(coffee.dt.date()),
            'desc': coffee.desc,
            'tod': '2001-01-01T{:%H:%M:%S}'.format(coffee.dt),
            'mins': coffee.dt.hour * 60 + coffee.dt.minute,
            'kind': classify(coffee.desc),
        })

    # Dump JSON object.
    json.dump({
        'days': days,
        'coffees': flat_coffees,
    }, sys.stdout, indent=2, sort_keys=True)

if __name__ == '__main__':
    dump_json(sys.argv[1])
