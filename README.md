## Repo omaa PWM:n kehitystyötä varten.

Huom! Master-branchiin ei saa koskea!!![1]  Siihen siirretään upstream-muutoksia git-svn:n avulla. Omat muutokset on *AINA* tehtävä muihin brancheihin!

[1] Pois lukien (tarvittaessa) .gitignore ja README.md.

Git-svm remote branchit ovat tätä kirjoitettaessa kuten seuraavassa:
```
  remotes/origin/git-svn
  remotes/origin/v1.7.1
```

Ensimmäinen on SVN:n trunk, toinen uusin release tag. Vastaava ```.git/config```-tiedoston kokoonpano olisi seuraava:

```
[svn-remote "svn"]
	url = http://pwm.googlecode.com/svn
	fetch = trunk:refs/remotes/origin/git-svn
	fetch = tags/v1.7.1:refs/remotes/origin/v1.7.1
```

Uusien release tagien julkaisun myötä voidaan lisätä uusia release tageja. PWM ilmeisesti siirtyy jossakin vaiheessa Githubiin (kts. https://groups.google.com/forum/#!topic/pwm-general/QRkZBu53hN8). Kun se tapahtuu, niin voidaan määrittää uusi upstream ja purkaa nämä viritykset.

Tämä järjestely on tehty seuraavan sivun vihjeiden perusteella: http://www.janosgyerik.com/practical-tips-for-using-git-with-large-subversion-repositories/

[pinjaliina]/(https://github.com/pinjaliina) @ 2015-03-25
