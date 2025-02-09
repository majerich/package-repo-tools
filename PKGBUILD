# Maintainer: Richard Majewski
pkgname=package-repo-tools
pkgver=2.0.0
pkgrel=1
pkgdesc="Tools for backing up and restoring Arch Linux package installations"
arch=('any')
url="https://github.com/majerich/package-repo-tools"
license=('MIT')
depends=('bash' 'curl' 'pacman' 'parallel')
optdepends=('yay: AUR package support')
backup=('etc/package-repo-tools.conf')
source=("$pkgname-$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
  cd "$srcdir/$pkgname-$pkgver"

  make DESTDIR="$pkgdir" PREFIX=/usr SYSCONFDIR=/etc install
}
