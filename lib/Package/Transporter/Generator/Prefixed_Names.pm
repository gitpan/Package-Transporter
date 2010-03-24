package Package::Transporter::Generator::Structured_Core;
use strict;
use warnings;
use Scalar::Util qw();
use parent qw(
	Package::Transporter::Generator
);
our $VERBOSE = 1;

sub ATB_PKG() { 0 };
sub ATB_SUGGESTIONS() { 1 };

sub _init {
	my ($self) = (shift);

	$self->[ATB_SUGGESTIONS] //=
		Package::Transporter::Generator::Suggested_Use::Suggestions->new();
	my %packages = ();
	my $current = [];
        foreach my $line (<DATA>) {
                next if ($line =~ m,^[\s\t]*\#,);
                chomp($line);
		if($line =~ m,\[(\w+)\],) {
			my $name = $1;
			unless(exists($packages{$name})) {
				$packages{$name} = [];
			}
			$current = $packages{$name};
		} else {
			push($current, split(/\t+/, $line));
		}
        }
        close(DATA);

	my $code = '';
	while(my ($pkg_name, $definitions) = each(%packages)) {
		$code .= "package $pkg_name\n";
		foreach my $definition (@$definitions) {
			if($definition->[2] eq 'alias') {
				if(defined()) {
					$code .= sprintf('*%s = *%s',
						$definition->[2],
						$definition->[2],
				}
			}
		}
	}

	return;
}

sub matcher {
	my ($self) = (shift);

	return(sub {
		return (exists($self->[ATB_DEFINITION]{$_[1]}) and
			exists($self->[ATB_DEFINITION]{$_[1]}{$_[2]}));

	});
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	unless(exists($self->[ATB_DEFINITION]{$_[1]})) {
	}
	unless(exists($self->[ATB_DEFINITION]{$_[1]}[$_[2]))) {
	}
	
	my $ref = Scalar::Util::blessed($_[0]) ? 'OBJECT' : ref($_[0]);
	my $suggested = $self->[ATB_SUGGESTIONS]->lookup($sub_name, $ref, scalar(@_));

	unless (defined($suggested)) {
		return($self->failure(undef, $sub_name, '::Suggested_Use [no suggestion found]'));
	}
	my ($load, $module) = @$suggested;
	
	my $sub_text;
	if ($load eq 'use') {
		$sub_text = sprintf(q{
my ($self, $verbose) = (shift(@_), shift(@_));
print STDERR qq{Loading suggested module '%s' to enable subroutine '%s'.\n} if ($verbose);
use %s;
return(\&%s) if (defined(&%s));
return(\&%s::%s) if (defined(&%s::%s));
return($self->failure(undef, '%s', q{::Suggested_Use ['use %s' had not the required effect]}));
		},
			$module, $sub_name,
			$module,
			$sub_name, $sub_name, 
			$module, $sub_name, $module, $sub_name,
			$sub_name, $module);
	} elsif ($load eq 'parent') {
		$sub_text = sprintf(q{
my ($self, $verbose) = (shift(@_), shift(@_));
print STDERR qq{Loading suggested parent '%s' to enable method '%s'.\n} if ($verbose);
use parent qw(%s);
my $can = UNIVERSAL::can($_[0], '%s');
return($can) if (defined($can));
return($self->failure(undef, '%s', q{::Suggested_Use ['use parent qw(%s)' had not the required effect]}));
		},
			$module, $sub_name,
			$module,
			$sub_name,
			$sub_name, $module);
	} else {
		return($self->failure(undef, $sub_name, "::Suggested_Use [invalid loading '$load']"));
	}

	return($pkg->transport(\$sub_text, $self, $VERBOSE, $_[0]));
}

1;

__DATA__
#FIXME: numeric::hex
# alias forward fatal?
# debug messages
# [text]
# chomp	* [chomp]
# [re]
# match($$)	'$_[0] &
# [op_binary]
# and($$)	>	'$_[0] & $_[1]'
# [fs]
# open		!
# [fatal]
# open		!

	'chomp'		=> 'text_chomp',
	'chop'		=> 'text_chop',
	'index'		=> 'text_index',
	'lc'		=> 'text_lc',
	'lcfirst,'	=> 'text_lcfirst,',
	'length'	=> 'text_length',
	'q//'		=> 'text_q//',
	'qq//'		=> 'text_qq//',
	'reverse'	=> 'text_reverse',
	'rindex,'	=> 'text_rindex,',
	'sprintf'	=> 'text_sprintf',
	'substr'	=> 'text_substr',
	'uc'		=> 'text_uc',
	'ucfirst'	=> 'text_ucfirst',
	'm//'		=> 're_match//',
	'pos'		=> 're_offset',
	'quotemeta'	=> 're_quotemeta',
	's///'		=> 're_substitute///',
	'split'		=> 're_split',
	'study'		=> 're_study',
	'qr//'		=> 're_qr//',
	'abs'		=> 'numeric_absolute',
	'atan2'		=> 'numeric_arctangent2',
	'cos'		=> 'numeric_cosinus',
	'exp'		=> 'numeric_exponential',
	'hex'		=> 'numeric_hexadecimal',
	'int'		=> 'numeric_integer',
	'log'		=> 'numeric_logarithm',
	'oct'		=> 'numeric_octal',
	'rand,'		=> 'numeric_random',
	'sin'		=> 'numeric_sinus',
	'sqrt'		=> 'numeric_square_root',
	'srand'		=> 'numeric_srandom',
	'pop'		=> 'array_pop_elements',
	'push'		=> 'array_push_elements',
	'shift'		=> 'array_shift_elements',
	'splice'	=> 'array_splice_elements',
	'unshift'	=> 'array_unshift_elements',
	'grep'		=> 'array_grep_elements',
	'join'		=> 'array_join_elements',
	'map'		=> 'array_map_elements',
	'qw//'		=> 'array_qw//',
	'reverse'	=> 'array_reverse_elements',
	'sort'		=> 'array_sort_elements',
	'delete'	=> 'hash_delete_pair',
	'each'		=> 'hash_each_pair',
	'exists'	=> 'hash_exists_pair',
	'keys'		=> 'hash_keys',
	'values'	=> 'hash_values',
	'binmode'	=> 'io_binmode',
	'close'		=> 'io_close',
	'closedir'	=> 'io_closedir',
	'dbmclose'	=> 'io_dbmclose',
	'dbmopen'	=> 'io_dbmopen',
	'eof'		=> 'io_eof',
	'fileno'	=> 'io_fileno',
	'flock'		=> 'io_flock',
	'format'	=> 'format', # gone
	'getc'		=> 'io_getc',
	'print'		=> 'io_print',
	'printf,'	=> 'io_printf,',
	'read'		=> 'io_read',
	'readdir'	=> 'io_readdir',
	'rewinddir'	=> 'io_rewinddir',
	'seek'		=> 'io_seek',
	'seekdir'	=> 'io_seekdir',
	'select,'	=> 'io_select,',
	'sysread'	=> 'io_sysread',
	'sysseek'	=> 'io_sysseek',
	'syswrite'	=> 'io_syswrite',
	'tell'		=> 'io_tell',
	'telldir,'	=> 'io_telldir,',
	'truncate'	=> 'io_truncate',
	'write'		=> 'io_write',

*	'chr'		=> 'convert_to_char', # replaced by \x?
*	'crypt'		=> 'convert_crypt',
*	'ord'		=> 'convert_to_ordinal',
*	'pack'		=> 'convert_pack',
*	'unpack'	=> 'convert_unpack',
*	'vec'		=> 'convert_vec',
	'%'		=> 'numeric_modulo',
	'&'		=> 'bitwise_and',
	'|'		=> 'bitwise_or',
	'^'		=> 'bitwise_xor',
	'~'		=> 'bitwise_negation',
	'<<'		=> 'bitwise_shift_left',
	'>>'		=> 'bitwise_shift_right',
	'-X'		=> 'fs_test_X',

	'chdir'		=> 'fs_chdir',
	'chmod'		=> 'fs_chmod',
	'chown'		=> 'fs_chown',
	'chroot'	=> 'fs_chroot',
	'fcntl'		=> 'fs_fcntl',
	'glob,'		=> 'fs_glob,',
	'ioctl'		=> 'fs_ioctl',
	'link'		=> 'fs_link',
	'lstat'		=> 'fs_lstat',
	'mkdir'		=> 'fs_mkdir',
	'open'		=> 'fs_open',
	'opendir'	=> 'fs_opendir',
	'readlink,'	=> 'fs_readlink,',
	'rename'	=> 'fs_rename',
	'rmdir'		=> 'fs_rmdir',
	'stat'		=> 'fs_stat',
	'symlink'	=> 'fs_symlink',
	'sysopen'	=> 'fs_sysopen',
	'umask'		=> 'fs_umask',
	'unlink,'	=> 'fs_unlink,',
	'utime'		=> 'fs_utime',

#Keywords related to the control flow of your Perl program - no prefix
	'caller'	=> 'caller',
	'continue'	=> 'continue',
	'die'		=> 'die',
	'do'		=> 'do',
	'dump'		=> 'dump', # gone already?
	'eval'		=> 'eval',
	'exit'		=> 'exit',
	'goto,'		=> 'goto,', # gone
	'last'		=> 'last',
	'next'		=> 'next',
	'redo'		=> 'redo',
	'return'	=> 'return',
	'sub'		=> 'sub',
	'wantarray'	=> 'wantarray', # gone

*	'say'		=> 'say',
*	'warn'		=> 'warn',

#Keywords related to switch - no prefix
	'break'		=> 'break',
	'continue'	=> 'continue',
	'given'		=> 'given',
	'when'		=> 'when',
	'default'	=> 'default',

#Keywords related to scoping - no prefix
	'caller'	=> 'caller',
	'import'	=> 'import',
	'local'		=> 'local',
	'my'		=> 'my',
	'our'		=> 'our',
	'state'		=> 'state',
	'package'	=> 'package',
	'use'		=> 'use',

#Miscellaneous functions - no prefix
	'defined'	=> 'defined',
	'dump'		=> 'dump',
	'eval'		=> 'eval',
	'formline'	=> 'formline', # gone
	'local'		=> 'local',
	'my'		=> 'my',
	'our,'		=> 'our,',
	'reset'		=> 'reset', # gone
	'scalar'	=> 'scalar',
	'state'		=> 'state',
	'undef'		=> 'undef',
	'wantarray'	=> 'wantarray', # gone

#Functions for processes and process groups
	'alarm'		=> 'os_alarm',
	'exec'		=> 'os_exec',
	'fork'		=> 'os_fork',
	'getpgrp'	=> 'os_getpgrp',
	'getppid'	=> 'os_getppid',
	'getpriority,'	=> 'os_getpriority,',
	'kill'		=> 'os_kill',
	'pipe'		=> 'os_pipe',
	'qx//'		=> 'os_qx//',
	'setpgrp'	=> 'os_setpgrp',
	'setpriority'	=> 'os_setpriority',
	'sleep,'	=> 'os_sleep,',
	'syscall'	=> 'os_syscall',
	'system'	=> 'os_system',
	'times'		=> 'os_times',
	'wait'		=> 'os_wait',
	'waitpid'	=> 'os_waitpid',

#Keywords related to perl modules - no prefix
	'do'		=> 'do',
	'import'	=> 'import',
	'no'		=> 'no',
	'package'	=> 'package',
	'require'	=> 'require',
	'use'		=> 'use',


