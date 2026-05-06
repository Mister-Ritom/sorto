<script lang="ts">
	import '../app.css';
	let { children } = $props();

	const currentYear = new Date().getFullYear();
</script>

<svelte:head>
	<title>Sorto — Your Dares. Your Money. Your Rules.</title>
	<meta name="description" content="Sorto is a high-energy social dare-and-performance platform. Post dares, complete challenges, and earn real money." />
</svelte:head>

<header class="glass">
	<div class="container" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
		<a href="/" class="display" style="font-size: 24px; display: flex; align-items: center; gap: 12px;">
			<img src="/favicon.png" alt="Sorto Logo" style="height: 32px; width: 32px; border-radius: 8px;" />
			<span class="text-gradient">SORTO</span>
		</a>

		<nav style="display: flex; gap: 32px; align-items: center;">
			<a href="/about" class="nav-link">About</a>
			<a href="/download" class="btn btn-primary" style="padding: 8px 20px; font-size: 14px;">Download</a>
		</nav>
	</div>
</header>

<main>
	{@render children()}
</main>

<footer style="padding: 120px 0; border-top: 1px solid var(--card-border); margin-top: 120px;">
	<div class="container">
		<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 64px; margin-bottom: 80px; align-items: start;">
			<div>
				<div style="display: flex; align-items: center; gap: 12px; margin-bottom: 24px;">
					<img src="/favicon.png" alt="Sorto Logo" style="height: 32px; width: 32px; border-radius: 8px;" />
					<h3 class="display" style="font-size: 24px;">SORTO</h3>
				</div>
				<p style="opacity: 0.6; font-size: 15px; line-height: 1.6; max-width: 300px;">
					The high-stakes social platform for dares and performances. Your money, your rules.
				</p>
			</div>
			<div>
				<h4 style="margin-bottom: 24px; font-size: 14px; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.4;">Product</h4>
				<ul style="list-style: none; display: flex; flex-direction: column; gap: 16px; font-size: 15px; opacity: 0.8;">
					<li><a href="/download">Download App</a></li>
					<li><a href="/#features">Features</a></li>
					<li><a href="/about">Our Mission</a></li>
				</ul>
			</div>
			<div>
				<h4 style="margin-bottom: 24px; font-size: 14px; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.4;">Legal</h4>
				<ul style="list-style: none; display: flex; flex-direction: column; gap: 16px; font-size: 15px; opacity: 0.8;">
					<li><a href="/privacy">Privacy Policy</a></li>
					<li><a href="/terms">Terms of Service</a></li>
				</ul>
			</div>
			<div>
				<h4 style="margin-bottom: 24px; font-size: 14px; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.4;">Connect</h4>
				<ul style="list-style: none; display: flex; flex-direction: column; gap: 16px; font-size: 15px; opacity: 0.8;">
					<li><a href="mailto:hello@ritom.in">Email Support</a></li>
					<li><a href="https://x.com/1ritomg" target="_blank">Twitter / X</a></li>
				</ul>
			</div>
		</div>
		
		<div style="padding-top: 40px; border-top: 1px solid var(--card-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 24px;">
			<p style="opacity: 0.4; font-size: 13px;">
				© {currentYear} Ananta (developed by Ritom). All rights reserved.
			</p>
			<div style="display: flex; gap: 32px; opacity: 0.4; font-size: 13px;">
				<span>Made with ♥ in India</span>
			</div>
		</div>
	</div>
</footer>

<style>
	.nav-link {
		font-weight: 600;
		font-size: 14px;
		opacity: 0.7;
	}
	.nav-link:hover {
		opacity: 1;
		color: var(--primary);
	}
	
	main {
		min-height: calc(100vh - 80px - 400px);
	}

	ul li a:hover {
		color: var(--primary);
		opacity: 1;
	}
</style>
