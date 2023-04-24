{ config, pkgs, lib, ... }:

lib.mkIf config.work.user.enable {
	home-manager.users.${config.work.user.username} = {
		programs = {
			git = {
				enable = true;
				# Git config
				userName  = "${config.work.user.github.username}";
				userEmail = "${config.work.user.github.email}";
			};

			kitty = {
				enable = true;
				settings = {
					background_opacity = "0.8";
					confirm_os_window_close = "0";
					cursor_shape = "underline";
					cursor_underline_thickness = "1.0";
					enable_audio_bell = "no";
					hide_window_decorations = "yes";
					update_check_interval = "0";
				};
				font.name = "JetBrainsMono Nerd Font";
			};

			zsh = {
				enable = true;
				# Enable firefox wayland
				profileExtra = "export MOZ_ENABLE_WAYLAND=1";

				# Install powerlevel10k
				plugins = with pkgs; [
					{
						name = "powerlevel10k";
						src = pkgs.zsh-powerlevel10k;
						file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
					}
					{
						name = "zsh-nix-shell";
						file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
						src = pkgs.zsh-nix-shell;
					}
				];

				initExtra = ''eval "$(direnv hook zsh)"'';
			};

			# Install gnome extensions using firefox
			firefox.enableGnomeExtensions = true;
		};

		home.file = {
			# Add zsh theme to zsh directory
			".config/zsh/zsh-theme.zsh" = {
				source = ../configs/zsh-theme.zsh;
				recursive = true;
			};

			# Add arkenfox user.js
			".mozilla/firefox/privacy/user.js" = lib.mkIf config.firefox-privacy.enable {
				source =
				"${(config.nur.repos.slaier.arkenfox-userjs.overrideAttrs (oldAttrs: {
					installPhase = ''
						cat ${../configs/firefox-user-overrides.js} >> user.js
						mkdir -p $out
						cp ./user.js $out/user.js
					'';
				}))}/user.js";
				recursive = true;
			};

			# Set firefox to privacy profile
			".mozilla/firefox/profiles.ini" = lib.mkIf config.firefox-privacy.enable {
				source = ../configs/firefox-profiles.ini;
				recursive = true;
			};

			# Add noise suppression microphone
			".config/pipewire/pipewire.conf.d/99-input-denoising.conf" = {
				source = ../configs/pipewire.conf;
				recursive = true;
			};

			# Add btop config
			".config/btop/btop.conf" = {
				source = ../configs/btop.conf;
				recursive = true;
			};

			# Add kitty session config
			".config/kitty/kitty.session" = {
				source = ../configs/kitty.session;
				recursive = true;
			};

			# Add kitty task managers session config
			".config/kitty/kitty-task-managers.session" = {
				source = ../configs/kitty-task-managers.session;
				recursive = true;
			};

			# Add nvchad
			".config/nvim" = {
				source = "${(pkgs.callPackage ../programs/self-built/nvchad.nix {})}";
				recursive = true;
			};

			".config/nvim/lua/custom/chadrc.lua" = {
				text = ''
					local M = {}
					M.ui = {theme = 'onedark'}
					M.plugins = 'custom.plugins'
					return M
				'';
				recursive = true;
				force = true;
			};

			".config/nvim/lua/custom/plugins.lua" = {
				text = ''
					local plugins = {
						{
							"nvim-lua/plenary.nvim",
							lazy = false
						},
						{
							"TimUntersberger/neogit",
							lazy = false
						},
						{
							"sQVe/sort.nvim",
							lazy = false
						},
						{
							"nvim-treesitter/nvim-treesitter",
							opts = {
								ensure_installed = {
									"awk",
									"bash",
									"c",
									"c_sharp",
									"cmake",
									"cpp",
									"css",
									"diff",
									"dockerfile",
									"gdscript",
									"git_config",
									"git_rebase",
									"gitattributes",
									"gitcommit",
									"gitignore",
									"html",
									"java",
									"javascript",
									"json",
									"lua",
									"markdown",
									"nix",
									"python",
									"rust",
									"tsx",
									"typescript",
									"vim"
								}
							}
						}
					}
					return plugins
				'';
				recursive = true;
				force = true;
			};
		};
	};
}
