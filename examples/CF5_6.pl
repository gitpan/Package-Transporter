package CF5;
use strict;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->package_constants('IS_', 'TRUE' => 1, 'FALSE' => 0);
};

package CF6;
use Package::Transporter sub{eval shift}, 'mix_in:CF5';

die() if (IS_TRUE == IS_FALSE);
