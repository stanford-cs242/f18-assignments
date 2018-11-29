import time
import re
import getpass

import requests
from bs4 import BeautifulSoup


# per-assignment breakdown weights
weights = {
    'Assignment 1: Lambda Theory - Program': 0.55,
    'Assignment 1: Lambda Theory - Written': 0.45,
    'Assignment 2: Lambda Practice - Written': 0.25,
    'Assignment 2: Lambda Practice - Program': 0.75,
    'Assignment 3: Collections API - Program': 0.8,
    'Assignment 3: Collections API - Written': 0.2,
    'Assignment 4: WebCoin - Programming': 0.8,
    'Assignment 4: WebCoin - Written': 0.2,
    'Assignment 5: WebAssembler': 1,
    'Assignment 6: Futures': 1,
    'Assignment 7: TCProof - Bugs': 0.3,
    'Assignment 7: TCProof - Program': 0.7,
    'Assignment 8: Roguelike': 1
}


def proc_score(stext):
    num, denom = [float(x) for x in stext.split(' / ')]
    print(stext, num, denom)
    return num * 100 / denom


def proc_late(ltext):
    latedays = 0
    dres = re.search(r'(\d+) Day', ltext)
    if dres:
        latedays += int(dres.group(1))
    hres = re.search(r'(\d+) Hour', ltext)
    if hres:
        latedays += 1
    mres = re.search(r'(\d+) Minute', ltext)
    if mres and not hres:
        latedays += 1

    return latedays


if __name__ == '__main__':
    username = input('Gradescope login email: ')
    password = getpass.getpass('Gradescope password: ')
    guestlecs = input('How many guest lectures did you attend? ')

    client = requests.session()
    res = client.get('https://www.gradescope.com/login')

    soup = BeautifulSoup(res.text, 'html.parser')

    ctoken = soup.find('meta', attrs={'name': 'csrf-token'})
    ctoken = ctoken.attrs['content']
    
    atoken = soup.find('input', attrs={'name':'authenticity_token'})
    atoken = atoken.attrs['value']

    data = {
        'session[email]': username,
        'session[password]': password,
        'authenticity_token': atoken,
        'utf8': '&#x2713;',
        'session_remember_me': '0'
    }
    headers = {
        'cookie': '; '.join([x.name + '=' + x.value for x in client.cookies]),
        'content-type': 'application/x-www-form-urlencoded',
        'X-CSRFToken': ctoken,
        'Referer': 'https://www.gradescope.com/login'
    }
    client.post('https://www.gradescope.com/login', data=data, headers=headers)

    res = client.get('https://www.gradescope.com/courses/19074')

    assignments = BeautifulSoup(res.text, 'html.parser').find(id='assignments-student-table')


    grades = [0] * 8
    ld_used = [0] * 8

    a8_graded = True
    for row in assignments.find_all('tr', role='row')[1:]:
        aname = row.find('th', class_='table--primaryLink').text

        if 'Final' in aname: continue

        submission = row.find(class_='submissionStatus').find_all('div')

        print(submission)

        latedays = 0
        if len(submission) == 2 and 'No Submission' in submission[1]:
            score = 0
        elif 'Assignment 8' in aname and len(submission) == 2 and 'Submitted' in submission[1]:
            a8_graded = False
            score = 90
        else:
            score = proc_score(submission[0].text)
            latedays = proc_late(submission[1].text) if len(submission) > 1 else 0

        print(aname, score, latedays)

        anum = int(re.search(r'\d+', aname).group(0))

        grades[anum - 1] += score * weights[aname]
        ld_used[anum - 1] = max(ld_used[anum-1], latedays)

    # handle latedays
    ld_remaining = 5
    for i, ld in enumerate(ld_used):
        ld_remaining -= ld
        if ld_remaining < 0:
            grades[i] = min(grades[i], 100 + 10 * ld_remaining)


    for i, g in enumerate(grades):
        print('Grade for Assignment %d: %.2f' % (i+1, g))
    if not a8_graded:
        print('**You\'ve submitted Assignment 8 but grades are not yet released; the score of 90 above is a placeholder. Check back once grades are released.**')

    print('Late days used: %d out of 5' % (5 - ld_remaining))


    # downweight lowest
    lidx = min(list(enumerate(grades[:-1])), key=lambda x: x[1])[0]

    for i, g in enumerate(grades):
        if i == lidx:
            grades[i] *= 0.05
        elif i == 7:
            grades[i] *= 0.15
        else:
            grades[i] *= 0.1

    grade = sum(grades)
    grade += 0.02 * float(guestlecs) / 3 * 100

    finals = [70, 80, 90, 100]
    for f in finals:
        print('If you got a %d on the final, your final grade would be %.2f.' % (f, grade + 0.18 * f))





