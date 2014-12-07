require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include zsh 
  include git
  include sublime_text
  include virtualbox
  include vagrant
  include dropbox
  include java
  include iterm2::stable
  include chrome
  include clojure
  include spotify
  #include vlc

  include osx::global::tap_to_click
  include osx::dock::disable_dashboard
  include osx::global::expand_save_dialog
  include osx::global::expand_print_dialog
  include osx::finder::empty_trash_securely
  include osx::finder::unhide_library
  include osx::finder::show_hidden_files
  include osx::finder::show_all_filename_extensions
  include osx::finder::no_file_extension_warnings
  class { 'osx::dock::position': position => 'left' }
  class { 'osx::global::natural_mouse_scrolling': enabled => false }
  class { 'osx::sound::interface_sound_effects': enable => false }
  class { 'osx::mouse::button_mode': mode => 2 }
  class { 'osx::mouse::swipe_between_pages': enabled => true }


  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { 'v0.6': }
  nodejs::version { 'v0.8': }
  nodejs::version { 'v0.10': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
