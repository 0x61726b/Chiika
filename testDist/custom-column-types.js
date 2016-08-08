(function() {
  var eXcell_animeProgress, eXcell_cImage, eXcell_score, eXcell_season, eXcell_title, eXcell_typeWithIcon;

  window.sortFunctions = {};

  eXcell_typeWithIcon = function(cell) {
    if (cell) {
      this.cell = cell;
      this.grid = this.cell.parentNode.grid;
    }
    this.edit = function() {};
    this.isDisabled = function() {
      return true;
    };
    this.setValue = function(val) {
      if (val === 'TV') {
        val = 'fa fa-television';
      }
      if (val === 'OVA') {
        val = 'glyphicon glyphicon-cd';
      }
      if (val === 'Movie') {
        val = 'fa fa-film';
      }
      if (val === 'Special') {
        val = 'fa fa-star';
      }
      if (val === 'ONA') {
        val = 'fa fa-chrome';
      }
      if (val === 'Music') {
        val = 'fa fa-music';
      }
      if (val === 'Normal') {
        val = '';
      }
      if (val === 'Novel') {
        val = '';
      }
      if (val === 'Oneshot') {
        val = '';
      }
      if (val === 'Doujinshi') {
        val = '';
      }
      if (val === 'Manwha') {
        val = '';
      }
      if (val === 'Manhua') {
        val = '';
      }
      return this.setCValue('<i class="' + val + '"></i>');
    };
    return this.baka = 42;
  };

  window.eXcell_animeType = eXcell_typeWithIcon;

  window.eXcell_animeType.prototype = new eXcell;

  window.eXcell_mangaType = eXcell_typeWithIcon;

  window.eXcell_mangaType.prototype = new eXcell;

  eXcell_score = function(cell) {
    if (cell) {
      this.cell = cell;
      this.grid = this.cell.parentNode.grid;
    }
    this.edit = function() {};
    this.isDisabled = function() {
      return true;
    };
    this.setValue = function(val) {
      return this.setCValue(val);
    };
    return this.baka = 42;
  };

  window.eXcell_animeScore = eXcell_score;

  window.eXcell_animeScore.prototype = new eXcell;

  window.eXcell_mangaScore = eXcell_score;

  window.eXcell_mangaScore.prototype = new eXcell;

  window.eXcell_animeScoreAverage = eXcell_score;

  window.eXcell_animeScoreAverage.prototype = new eXcell;

  window.eXcell_mangaScoreAverage = eXcell_score;

  window.eXcell_mangaScoreAverage.prototype = new eXcell;

  eXcell_animeProgress = function(cell) {
    if (cell) {
      this.cell = cell;
      this.grid = this.cell.parentNode.grid;
    }
    this.edit = function() {};
    this.isDisabled = function() {
      return true;
    };
    this.setValue = function(val) {
      return this.setCValue("<div class='progress-bar thin' sort-data=" + val + "> <div class='indigo' style=width:" + val + "%; /> </div>", val);
    };
    this.getValue = function() {
      return parseInt(this.cell.firstChild.getAttribute('sort-data'));
    };
    return this.baka = 42;
  };

  window.eXcell_animeProgress = eXcell_animeProgress;

  window.eXcell_animeProgress.prototype = new eXcell;

  window.eXcell_mangaProgress = eXcell_animeProgress;

  window.eXcell_mangaProgress.prototype = new eXcell;

  eXcell_title = function(cell) {
    if (cell) {
      this.cell = cell;
      this.grid = this.cell.parentNode.grid;
    }
    this.edit = function() {};
    this.isDisabled = function() {
      return true;
    };
    this.setValue = function(val) {
      return this.setCValue(val);
    };
    return this.baka = 42;
  };

  window.eXcell_animeTitle = eXcell_title;

  window.eXcell_animeTitle.prototype = new eXcell;

  window.eXcell_mangaTitle = eXcell_title;

  window.eXcell_mangaTitle.prototype = new eXcell;

  eXcell_season = function(cell) {
    if (cell) {
      this.cell = cell;
      this.grid = this.cell.parentNode.grid;
    }
    this.edit = function() {};
    this.isDisabled = function() {
      return true;
    };
    this.setValue = function(val) {
      return this.setCValue(val);
    };
    return this.baka = 42;
  };

  window.eXcell_animeSeason = eXcell_season;

  window.eXcell_animeSeason.prototype = new eXcell;

  window.eXcell_mangaSeason = eXcell_season;

  window.eXcell_mangaSeason.prototype = new eXcell;

  eXcell_score = function(cell) {
    if (cell) {
      this.cell = cell;
      this.grid = this.cell.parentNode.grid;
    }
    this.edit = function() {};
    this.isDisabled = function() {
      return true;
    };
    this.setValue = function(val) {
      return this.setCValue(val);
    };
    return this.baka = 42;
  };

  window.eXcell_score = eXcell_score;

  window.eXcell_score.prototype = new eXcell;

  eXcell_cImage = function(cell) {
    if (cell) {
      this.cell = cell;
      this.grid = this.cell.parentNode.grid;
    }
    this.edit = function() {};
    this.isDisabled = function() {
      return true;
    };
    this.setValue = function(val) {
      return this.setCValue("<img src='" + val.image + "' style='height: 100px' />");
    };
    return this.baka = 42;
  };

  window.eXcell_cImage = eXcell_cImage;

  window.eXcell_cImage.prototype = new eXcell;

}).call(this);
