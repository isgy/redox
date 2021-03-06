build/filesystem.bin: filesystem.toml build/bootloader build/kernel
	-$(FUMOUNT) build/filesystem/ || true
	rm -rf $@  $@.partial build/filesystem/
	dd if=/dev/zero of=$@.partial bs=1048576 count=256
	cargo run --manifest-path redoxfs/Cargo.toml --release --bin redoxfs-mkfs $@.partial
	mkdir -p build/filesystem/
	cargo build --manifest-path redoxfs/Cargo.toml --release --bin redoxfs
	cargo run --manifest-path redoxfs/Cargo.toml --release --bin redoxfs -- $@.partial build/filesystem/
	sleep 2
	pgrep redoxfs
	cp filesystem.toml build/bootloader build/kernel build/filesystem/
	cargo run --manifest-path installer/Cargo.toml --release -- $(INSTALLER_FLAGS) -c $< build/filesystem/
	sync
	-$(FUMOUNT) build/filesystem/ || true
	rm -rf build/filesystem/
	mv $@.partial $@

mount: FORCE
	mkdir -p build/filesystem/
	cargo build --manifest-path redoxfs/Cargo.toml --release --bin redoxfs
	cargo run --manifest-path redoxfs/Cargo.toml --release --bin redoxfs -- build/harddrive.bin build/filesystem/
	sleep 2
	pgrep redoxfs

unmount: FORCE
	sync
	-$(FUMOUNT) build/filesystem/ || true
	rm -rf build/filesystem/
