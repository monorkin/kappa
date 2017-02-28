//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require ace-rails-ap
//= require ace/theme-xcode

$.turbo.use('turbolinks:load', 'turbolinks:request-start');

$(document).ready(function() {
  initializeEditor();
  attachTemplatePresetListener();
});

function initializeEditor() {
  var $editor = $('#editor');
  if ($editor.length === 0) return;

  var $value = $('#setting_value');
  if ($value.length === 0) return;

  var editor = ace.edit('editor');
  editor.getSession().setMode("ace/mode/json");
  editor.setTheme("ace/theme/xcode");
  editor.getSession().setTabSize(2);
  editor.getSession().setUseWrapMode(true);

  editor.getSession().on('change', function(){
    var value = editor.getSession().getValue();
    // localStorage.setItem('template', value);
    $value.val(value);
  });

  var jsonString = editor.getValue();
  var json = null;

  try {
    json = JSON.parse(jsonString);
  }
  catch(_e) {
    json = {};
  }

  jsonString = JSON.stringify(json, null, '\t');

  editor.setValue(jsonString);

  $editor.data('editor', editor);
};

function attachTemplatePresetListener() {
  var $editor = $('#editor');
  if ($editor.length === 0) return;

  var $presets = $('[data-preset]');
  if ($presets.length === 0) return;

  $presets.each(function(index, object) {
    var $object = $(object);
    $object.on('click', function(e) {
      e.preventDefault();
      var url = $object.attr('href');
      $.ajax({
        url: url
      }).done(function(data) {
        var editor = $editor.data('editor');
        editor.setValue(JSON.stringify(data, null, '\t'));
      });
    });
  });
};
