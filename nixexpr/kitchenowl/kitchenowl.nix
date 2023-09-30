{ lib
, stdenv
, coreutils
, stdenvNoCC
, fetchFromGitHub
, python311
, callPackage
, fetchzip
, uwsgi
, python311Packages
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kitchenowl-backend";
  version = "76";

  src = fetchFromGitHub {
    owner = "TomBursch";
    repo = "kitchenowl-backend";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cffogyVTv1ogXtCBLo+aUifRwU5kLYBo9GUe8DtnVTg=";
  };

  buildPhase = ''
    echo "Adding pyhome to ini file"
    echo -e "\npyhome = ${finalAttrs.python}" >> wsgi.ini
    echo "pythonpath = $out" >> wsgi.ini
    echo "patching wsgi file"
    substituteInPlace wsgi.ini --replace wsgi.py "$out/wsgi.py"
    '';

  installPhase = ''
    mkdir -p $out
    mv app templates migrations $out
    mv wsgi.ini wsgi.py manage.py upgrade_default_items.py $out
    '';

  passthru = {
    uwsgi = callPackage ./uwsgi {
      plugins = [ "gevent" "python3" ];
      python3 = finalAttrs.python;
    };
    nltk_data = stdenvNoCC.mkDerivation (finalAttrs: {
      name = "nltk-data-for-kitchenowl";
      src = fetchzip {
        url = "https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/taggers/averaged_perceptron_tagger.zip";
        hash = "sha256-RBcFxETVjfF5VGiQ8P2Yy4HpAsIE8R50d9xJ3DW0aqA=";
      };
      buildPhase = ''
        OUT_DIR="$out/taggers/averaged_perceptron_tagger"
        mkdir -p "$OUT_DIR"
        mv * "$OUT_DIR"
      '';
    });
  };
  python = python311.withPackages (ps: let callPackage = ps.callPackage; in [
    ps.alembic
    ps.appdirs
    ps.apscheduler
    ps.attrs
    ps.autopep8
    ps.bcrypt
    ps.beautifulsoup4
    ps.bidict
    ps.black
    ps.blinker
    ps.blurhash
    ps.certifi
    ps.cffi
    ps.charset-normalizer
    ps.click
    ps.contourpy
    ps.cycler
    (callPackage ./dbscan1d.nix {})
    ps.extruct
    ps.flake8
    ps.flask
    (callPackage ./flask-apscheduler.nix {})
    ps.flask-basicauth
    ps.flask-bcrypt
    ps.flask-jwt-extended
    ps.flask-migrate
    ps.flask-socketio
    ps.flask-sqlalchemy
    ps.fonttools
    ps.gevent
    ps.greenlet
    #ps.gunicorn
    ps.h11
    ps.html-text
    ps.html5lib
    ps.idna
    (callPackage ./ingredient-parser-nlp.nix {})
    ps.iniconfig
    ps.isodate
    ps.itsdangerous
    ps.jinja2
    ps.joblib
    ps.jstyleson
    ps.kiwisolver
    ps.lark
    ps.lxml
    ps.mako
    ps.markupsafe
    ps.marshmallow
    ps.matplotlib
    ps.mccabe
    ps.mf2py
    (callPackage ./mlxtend.nix {})
    ps.mypy-extensions
    ps.nltk
    ps.numpy
    ps.packaging
    ps.pandas
    ps.pathspec
    ps.pillow
    ps.platformdirs
    ps.pluggy
    ps.prometheus-client
    ps.prometheus-flask-exporter
    ps.psycopg2
    ps.py
    ps.pycodestyle
    ps.pycparser
    ps.pyflakes
    ps.pyjwt
    ps.pyparsing
    ps.pyrdfa3
    ps.pytest
    ps.python-crfsuite
    ps.python-dateutil
    ps.python-editor
    ps.python-engineio
    ps.python-socketio
    ps.pytz
    ps.pytz-deprecation-shim
    ps.rdflib
    #ps.rdflib-jsonld
    ps.recipe-scrapers
    ps.regex
    ps.requests
    ps.scikit-learn
    ps.scipy
    ps.setuptools-scm
    ps.six
    ps.soupsieve
    ps.sqlalchemy
    ps.threadpoolctl
    ps.toml
    ps.tomli
    ps.tqdm
    ps.typed-ast
    ps.types-beautifulsoup4
    ps.types-html5lib
    ps.types-requests
    ps.types-urllib3
    ps.typing-extensions
    ps.tzdata
    ps.tzlocal
    ps.urllib3
    ps.w3lib
    ps.webencodings
    ps.werkzeug
    ps.wsproto
    ps.zope_event
    ps.zope_interface

  ]);

  meta = with lib; {
    description = "Backend for the KitchenOwl app";
    homepage = "https://github.com/TomBursch/kitchenowl-backend";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
})