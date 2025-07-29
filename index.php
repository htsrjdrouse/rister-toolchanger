<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HTS Resources - Advanced Multi-Modal Manufacturing Solutions</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
        }
        
        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 0;
        }
        
        .logo {
            font-size: 1.8rem;
            font-weight: bold;
            color: #4a5568;
            text-decoration: none;
        }
        
        .logo span {
            color: #667eea;
        }
        
        .nav-links {
            display: flex;
            list-style: none;
            gap: 2rem;
        }
        
        .nav-links a {
            text-decoration: none;
            color: #4a5568;
            font-weight: 500;
            transition: color 0.3s ease;
            position: relative;
        }
        
        .nav-links a:hover {
            color: #667eea;
        }
        
        .nav-links a::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 0;
            height: 2px;
            background: #667eea;
            transition: width 0.3s ease;
        }
        
        .nav-links a:hover::after {
            width: 100%;
        }
        
        main {
            margin-top: 80px;
        }
        
        .hero {
	    background: linear-gradient(135deg, rgba(102, 126, 234, 0.85), rgba(118, 75, 162, 0.85)), 
            url('images/printer-hero.jpg') center/cover no-repeat;
min-height: 70vh;
            color: white;
            padding: 100px 0;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse"><path d="M 10 0 L 0 0 0 10" fill="none" stroke="white" stroke-width="0.5" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)"/></svg>') repeat;
            opacity: 0.3;
        }
        /*
        .hero-content {
            position: relative;
            z-index: 2;
	}
	*/

	.hero-content {
	    background: rgba(0, 0, 0, 0.3);
	    padding: 40px;
	    border-radius: 20px;
	    backdrop-filter: blur(10px);
	    max-width: 800px;
	    margin: 0 auto;
	}

        
        .hero h1 {
            font-size: 3.5rem;
            margin-bottom: 1rem;
            font-weight: 700;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .hero-subtitle {
            font-size: 1.3rem;
            margin-bottom: 2rem;
            opacity: 0.9;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .cta-button {
            display: inline-block;
            background: white;
            color: #667eea;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
        }
        
        .cta-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.3);
            background: #f8f9ff;
        }
        
        .platform-section {
            background: white;
            padding: 80px 0;
        }
        
        .section-header {
            text-align: center;
            margin-bottom: 60px;
        }
        
        .section-header h2 {
            font-size: 2.5rem;
            color: #2d3748;
            margin-bottom: 1rem;
        }
        
        .section-header p {
            font-size: 1.2rem;
            color: #718096;
            max-width: 600px;
            margin: 0 auto;
        }
        
        .platform-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 40px;
            margin-bottom: 60px;
        }
        
        .platform-card {
            background: linear-gradient(135deg, #f8f9ff, #ffffff);
            border-radius: 20px;
            padding: 40px 30px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border: 1px solid rgba(102, 126, 234, 0.1);
        }
        
        .platform-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 50px rgba(102, 126, 234, 0.2);
        }
        
        .platform-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 2rem;
            color: white;
        }
        
        .platform-card h3 {
            font-size: 1.5rem;
            color: #2d3748;
            margin-bottom: 15px;
        }
        
        .platform-card p {
            color: #718096;
            line-height: 1.6;
        }
        
        .capabilities-section {
            background: linear-gradient(135deg, #f7fafc, #edf2f7);
            padding: 80px 0;
        }
        
        .capabilities-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
        }
        
        .capability-item {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
        }
        
        .capability-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
        }
        
        .capability-item h4 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 1.2rem;
        }
        
        .technical-specs {
            background: white;
            padding: 80px 0;
        }
        
        .specs-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: center;
        }
        
        .specs-content h3 {
            font-size: 2rem;
            color: #2d3748;
            margin-bottom: 20px;
        }
        
        .specs-list {
            list-style: none;
            space-y: 10px;
        }
        
        .specs-list li {
            padding: 10px 0;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
        }
        
        .specs-list li:last-child {
            border-bottom: none;
        }
        
        .specs-visual {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 20px;
            padding: 40px;
            color: white;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .specs-visual::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }
        
        @keyframes rotate {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .github-section {
            background: #2d3748;
            color: white;
            padding: 60px 0;
            text-align: center;
        }
        
        .github-content h3 {
            font-size: 2rem;
            margin-bottom: 20px;
        }
        
        .github-button {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            margin: 10px;
            transition: all 0.3s ease;
        }
        
        .github-button:hover {
            background: #764ba2;
            transform: translateY(-2px);
        }
        
        .contact-section {
            background: white;
            padding: 80px 0;
        }
        
        .contact-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: start;
        }
        
        .contact-form {
            background: #f8f9ff;
            padding: 40px;
            border-radius: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #4a5568;
            font-weight: 500;
        }
        
        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }
        
        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .submit-btn {
            background: #667eea;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
        }
        
        .submit-btn:hover {
            background: #764ba2;
            transform: translateY(-2px);
        }
        
        footer {
            background: #2d3748;
            color: white;
            text-align: center;
            padding: 40px 0;
        }
        
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #4a5568;
            cursor: pointer;
        }
        
        @media (max-width: 768px) {
            .mobile-menu-toggle {
                display: block;
            }
            
            .nav-links {
                display: none;
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background: white;
                flex-direction: column;
                padding: 20px;
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            }
            
            .nav-links.active {
                display: flex;
            }
            
            .hero h1 {
                font-size: 2.5rem;
            }
            
            .hero-subtitle {
                font-size: 1.1rem;
            }
            
            .specs-container,
            .contact-grid,
            .example-content {
                grid-template-columns: 1fr;
                gap: 40px;
            }
            
            .platform-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .fade-in {
            opacity: 0;
            transform: translateY(30px);
            transition: all 0.6s ease;
        }
        
        .fade-in.visible {
            opacity: 1;
            transform: translateY(0);
        }
        
        .oem-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(102, 126, 234, 0.2);
        }
    </style>
</head>
<body>
    <header>
        <nav class="container">
            <a href="#" class="logo">HTS <span>Resources</span></a>
            <ul class="nav-links" id="navLinks">
                <li><a href="#platform">Platform</a></li>
                <li><a href="#capabilities">Capabilities</a></li>
                <li><a href="#oem">OEM Components</a></li>
                <li><a href="#github">Open Source</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
            <button class="mobile-menu-toggle" id="mobileToggle">☰</button>
        </nav>
    </header>

    <main>
        <section class="hero">
            <div class="container">
                <div class="hero-content fade-in">
                    <h1>Advanced Multi-Modal Manufacturing</h1>
                    <p class="hero-subtitle">
                        Expert implementation of innovative manufacturing solutions combining 3D printing, liquid handling, and imaging for DIY makers, biotechnology, and semiconductor applications
                    </p>
                    <a href="#contact" class="cta-button">Get Custom Quote</a>
                </div>
            </div>
        </section>

        <section id="platform" class="platform-section">
            <div class="container">
                <div class="section-header fade-in">
                    <h2>Multi-Modal 3D Printing</h2>
                    <p>Integrating 3D printing with precision liquid handling and high-resolution imaging through our expert implementation of the innovative Rister toolchanger architecture</p>
                </div>
                
                <div class="platform-grid">
                    <div class="platform-card fade-in">
                        <div class="platform-icon">🖨️</div>
                        <h3>FDM 3D Printing</h3>
                        <p>Dual extruder system with advanced filament sensors, multi-material capabilities, and precision temperature control for complex geometries</p>
                    </div>
                    
                    <div class="platform-card fade-in">
                        <div class="platform-icon">💧</div>
                        <h3>Precision Liquid Handling and Microfluidics</h3>
                        <p>Automated pipette systems with μL-level precision dispensing, integrated wash stations and multi-liquid workflows</p>
                    </div>
                    
                    <div class="platform-card fade-in">
                        <div class="platform-icon">📷</div>
                        <h3>High-Resolution Imaging</h3>
                        <p>16MP programmable focus camera with real-time streaming, automated capture, and quality control integration</p>
                    </div>
                 <!--   
                    <div class="platform-card fade-in">
                        <div class="platform-icon">🔗</div>
                        <h3>Microfluidics Integration</h3>
                        <p>Custom Arduino-controlled systems for complex fluid handling, pressure compensation, and automated protocols</p>
		    </div>
		 -->
		</div>


                <div class="equipment-showcase" style="margin-top: 60px;">
                    <div class="equipment-container" style="display: grid; grid-template-columns: 1fr 1fr; gap: 60px; align-items: center;">
                        <div class="equipment-info fade-in">
                            <h3 style="color: #2d3748; margin-bottom: 20px; font-size: 2rem;">Multi-Modal Platform</h3>
                            <p style="color: #718096; line-height: 1.7; margin-bottom: 20px; font-size: 1.1rem;">
                                This is our custom-built Voron Trident 3D printer adapted with the Rister multi-modal toolchanger system. The multiple tools visible at the top enable seamless switching between FDM printing, liquid dispensing, and imaging operations.
                            </p>

                            <div style="margin-bottom: 25px;">
                                <h4 style="color: #667eea; margin-bottom: 10px;">Visible Components:</h4>
                                <ul style="color: #718096; line-height: 1.8;">
                                    <li>Multiple toolheads for different operations</li>
                                    <li>Precision linear motion system</li>
                                    <li>Professional-grade frame construction</li>
                                    <li>Integrated electronics and control systems</li>
                                    <li>Modular toolchanging architecture</li>
                                </ul>
                            </div>
                            
                            <div style="display: flex; gap: 15px; margin-top: 25px;">
                                <a href="https://github.com/htsrjdrouse/rister-toolchanger" 
                                   target="_blank" 
                                   style="background: #667eea; color: white; padding: 12px 25px; text-decoration: none; border-radius: 8px; font-weight: 600; transition: all 0.3s ease;">
                                    View Technical Details
                                </a>
                                <a href="#contact" 
                                   style="background: transparent; color: #667eea; padding: 12px 25px; text-decoration: none; border-radius: 8px; border: 2px solid #667eea; font-weight: 600; transition: all 0.3s ease;">
                                    Request Quote
                                </a>
                            </div>
                        </div>

                        <div class="equipment-image fade-in" style="text-align: center;">
                            <img src="images/printer-main.jpg" 
                                 alt="HTS Resources Multi-Modal 3D Printer with Rister Toolchanger" 
                                 style="width: 100%; max-width: 500px; height: auto; border-radius: 15px; box-shadow: 0 20px 50px rgba(0,0,0,0.2); transition: transform 0.3s ease;">
                            <p style="color: #718096; font-size: 0.9rem; margin-top: 15px; font-style: italic;">
                                Custom Voron Trident with Rister Multi-Modal Toolchanger
                            </p>
                        </div>
                    </div>
                </div>













            </div>
        </section>

        <section id="capabilities" class="capabilities-section">
            <div class="container">
                <div class="section-header fade-in">
                    <h2>Manufacturing Capabilities</h2>
                    <p>Comprehensive services from concept to finished product</p>
                </div>
                
		<div class="capabilities-grid">
		   <!--
                    <div class="capability-item fade-in">
                        <h4>Custom User Interface Development</h4>
                        <p>Intuitive web-based interfaces that allow end users to craft G-code for specialized applications without programming knowledge</p>
		    </div>
		   -->
                    <div class="capability-item fade-in">
                        <h4>DIY Personal Manufacturing</h4>
                        <p>Advanced multi-modal capabilities for makers and hobbyists seeking professional-grade manufacturing tools and workflows</p>
                    </div>
                    <div class="capability-item fade-in">
                        <h4>Biotechnology Applications</h4>
                        <p>Precision liquid handling integrated with 3D printing for biotech research, sample preparation, and automated protocols</p>
                    </div>
                    
                    <div class="capability-item fade-in">
                        <h4>Semiconductor Manufacturing</h4>
                        <p>High-precision tooling and process control for semiconductor research, prototyping, and specialized manufacturing needs</p>
                    </div>
                    <div class="capability-item fade-in">
                        <h4>Custom Implementation Services</h4>
                        <p>Expert consultation and implementation of multi-modal manufacturing solutions tailored to your specific requirements</p>
                    </div>
                    <div class="capability-item fade-in">
                        <h4>Training & Support</h4>
                        <p>Comprehensive training on multi-modal systems, ongoing technical support, and custom workflow development</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="example-section" style="background: #f8f9ff; padding: 80px 0;">
            <div class="container">
                <div class="section-header fade-in">
                    <h2>Featured Example: G-code Editor for Lab Automation</h2>
                    <p>Converting 3D printers into lab automation platforms with custom user interfaces</p>
                </div>
                
                <div class="example-content" style="display: grid; grid-template-columns: 1fr 1fr; gap: 60px; align-items: center;">
                    <div class="example-info fade-in">
                        <h3 style="color: #2d3748; margin-bottom: 20px;">Lab Automation Interface</h3>
                        <p style="color: #718096; line-height: 1.7; margin-bottom: 20px;">
                            We developed a custom G-code editor that allows lab technicians to design complex automation workflows without programming knowledge. This example demonstrates DNA thermocycling amplification with per-cycle visualization.
                        </p>
                        
                        <div style="margin-bottom: 25px;">
                            <h4 style="color: #667eea; margin-bottom: 10px;">Key Features:</h4>
                            <ul style="color: #718096; line-height: 1.8;">
                                <li>Visual workflow design for lab automation</li>
                                <li>Real-time G-code generation and preview</li>
                                <li>Integration with liquid handling systems</li>
                                <li>Per-cycle process visualization</li>
                                <li>User-friendly interface for non-programmers</li>
                            </ul>
                        </div>
                        
                        <div style="display: flex; gap: 15px; margin-top: 25px;">
                            <a href="https://www.htsresources.com/gcode_editor_for_labautomation/index.php" 
                               target="_blank" 
                               style="background: #667eea; color: white; padding: 12px 25px; text-decoration: none; border-radius: 8px; font-weight: 600; transition: all 0.3s ease;">
                                View Live Demo
                            </a>
                            <a href="#contact" 
                               style="background: transparent; color: #667eea; padding: 12px 25px; text-decoration: none; border-radius: 8px; border: 2px solid #667eea; font-weight: 600; transition: all 0.3s ease;">
                                Request Custom UI
                            </a>
                        </div>
                    </div>
                    
                    <div class="example-visual fade-in" style="background: white; border-radius: 15px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); text-align: center;">
                        <div style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
                            <h4 style="margin: 0; font-size: 1.3rem;">Lab Automation Workflow</h4>
                        </div>
                        
                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin-bottom: 20px;">
                            <div style="background: #f0f4ff; padding: 15px; border-radius: 8px; text-align: center;">
                                <div style="font-size: 1.5rem; margin-bottom: 5px;">🧪</div>
                                <small style="color: #667eea; font-weight: 600;">Sample Prep</small>
                            </div>
                            <div style="background: #f0f4ff; padding: 15px; border-radius: 8px; text-align: center;">
                                <div style="font-size: 1.5rem; margin-bottom: 5px;">🌡️</div>
                                <small style="color: #667eea; font-weight: 600;">Thermocycling</small>
                            </div>
                            <div style="background: #f0f4ff; padding: 15px; border-radius: 8px; text-align: center;">
                                <div style="font-size: 1.5rem; margin-bottom: 5px;">📊</div>
                                <small style="color: #667eea; font-weight: 600;">Data Analysis</small>
                            </div>
                            <div style="background: #f0f4ff; padding: 15px; border-radius: 8px; text-align: center;">
                                <div style="font-size: 1.5rem; margin-bottom: 5px;">📈</div>
                                <small style="color: #667eea; font-weight: 600;">Visualization</small>
                            </div>
                        </div>
                        
                        <p style="color: #718096; font-size: 0.9rem; margin: 0;">
                            DNA amplification process with integrated imaging and real-time monitoring
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <section id="oem" class="oem-section" style="background: white; padding: 80px 0;">
            <div class="container">
                <div class="section-header fade-in">
                    <h2>OEM Components & Specialized Products</h2>
                    <p>Cutting-edge solutions for manufacturing, research and product development</p>
                </div>
                
                <div class="oem-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 40px;">
                    <div class="oem-card fade-in" style="background: linear-gradient(135deg, #f8f9ff, #ffffff); border-radius: 15px; padding: 30px; box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1); transition: all 0.3s ease;">
                        <div style="background: linear-gradient(135deg, #667eea, #764ba2); width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 20px;">
                            <span style="color: white; font-size: 1.5rem;">⚡</span>
                        </div>
                        <h3 style="color: #2d3748; margin-bottom: 15px;">Piezoelectric Dispensing System</h3>
			<p style="color: #718096; line-height: 1.6; margin-bottom: 15px;">
	Complete high-voltage piezoelectric dispensing solution with up to 100V amplifiers compatible with Arduino/Teensy microcontrollers, integrated with high-speed droplet visualization using synchronized LED flash and Arducam focusing camera with microsecond timing precision.
                        </p>
                        <div style="font-size: 0.9rem; color: #667eea; font-weight: 600;">
			    • High Voltage Amplifiers (100V)<br>
			    • High-Speed Droplet Imaging<br>
			    • Microsecond Flash Synchronization<br>
			    • Arduino/Teensy Compatible

                        </div>
                    </div>
                    
                    
                    <div class="oem-card fade-in" style="background: linear-gradient(135deg, #f8f9ff, #ffffff); border-radius: 15px; padding: 30px; box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1); transition: all 0.3s ease;">
                        <div style="background: linear-gradient(135deg, #667eea, #764ba2); width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 20px;">
                            <span style="color: white; font-size: 1.5rem;">🚿</span>
                        </div>
                        <h3 style="color: #2d3748; margin-bottom: 15px;">Microfluidics System</h3>
			<p style="color: #718096; line-height: 1.6; margin-bottom: 15px;">
Integrated microfluidics platform featuring automated wash stations for pipette tip recycling, pressure compensation vessel (PCV) with electrocaloric liquid level sensing, syringe pump with stepper motor control, and servo-driven stop cock valves for precise 4-position flow control.
                        </p>
			<div style="font-size: 0.9rem; color: #667eea; font-weight: 600;">
			• Automated Wash Stations<br>
			• Pressure Compensation Vessel<br>
			• Stepper Motor Syringe PumpM<br>
			• 4-Position Servo Valves
                        </div>
                    </div>
                    
                    <div class="oem-card fade-in" style="background: linear-gradient(135deg, #f8f9ff, #ffffff); border-radius: 15px; padding: 30px; box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1); transition: all 0.3s ease;">
                        <div style="background: linear-gradient(135deg, #667eea, #764ba2); width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 20px;">
                            <span style="color: white; font-size: 1.5rem;">💉</span>
                        </div>
                        <h3 style="color: #2d3748; margin-bottom: 15px;">Voron Trident Multi-Modal 3D Printer</h3>
			<p style="color: #718096; line-height: 1.6; margin-bottom: 15px;">
Modified Voron Trident 3D printer adapted for advanced toolchanging capabilities, running the Rister multi-modal Klipper-based software for seamless integration of multiple manufacturing processes in a single platform.
                        </p>
			<div style="font-size: 0.9rem; color: #667eea; font-weight: 600;">
			• Voron Trident Platform<br>
			• Rister Toolchanging Software<br>
			• Klipper-Based Control<br>
			• Multi-Modal Integration
                        </div>
                    </div>
                    
                    <div class="oem-card fade-in" style="background: linear-gradient(135deg, #f8f9ff, #ffffff); border-radius: 15px; padding: 30px; box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1); transition: all 0.3s ease;">
                        <div style="background: linear-gradient(135deg, #667eea, #764ba2); width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 20px;">
                            <span style="color: white; font-size: 1.5rem;">🔄</span>
                        </div>
                        <h3 style="color: #2d3748; margin-bottom: 15px;">Multi-Modal Tooling Suite</h3>
			<p style="color: #718096; line-height: 1.6; margin-bottom: 15px;">
Comprehensive tooling ecosystem including FDM extruders for precision 3D printing, liquid dispensers connected to servo-controlled linear actuators for automated fluid handling, and high-resolution cameras for real-time monitoring and quality control integration.
                        </p>
                        <div style="font-size: 0.9rem; color: #667eea; font-weight: 600;">
			• FDM Extruders<br>
			• Linear Actuator Liquid Dispensers<br>
			• High-Resolution Cameras<br>
			• Integrated Tool Control

                        </div>
                    </div>
                </div>
                
                <div class="oem-cta" style="text-align: center; margin-top: 60px;">
                    <div class="fade-in" style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 40px; border-radius: 20px; max-width: 800px; margin: 0 auto;">
                        <h3 style="margin-bottom: 15px; font-size: 1.8rem;">Research Partnerships</h3>
                        <p style="margin-bottom: 25px; opacity: 0.9; font-size: 1.1rem;">
                            Partnering with researchers to push the boundaries of piezoelectric dispensing
                        </p>
                        <div style="display: flex; gap: 20px; justify-content: center; flex-wrap: wrap;">
                            <a href="https://www.htsresources.com/oem-components.php" target="_blank" style="background: white; color: #667eea; padding: 12px 25px; text-decoration: none; border-radius: 8px; font-weight: 600; transition: all 0.3s ease;">
                                View Full OEM Catalog
                            </a>
                            <a href="#contact" style="background: transparent; color: white; padding: 12px 25px; text-decoration: none; border-radius: 8px; border: 2px solid white; font-weight: 600; transition: all 0.3s ease;">
                                Request OEM Quote
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
            <div class="container">
                <div class="specs-container">
		    <div class="specs-content fade-in">
                        <h3><font color=white>Technical Specifications</font></h3>
                        <ul class="specs-list">
			<font color=white>
                            <li><span>Build Volume</span><span>480×380×250mm</span></li>
                            <li><span>Positioning Accuracy</span><span>±0.025mm</span></li>
                            <li><span>Liquid Dispensing</span><span>μL precision</span></li>
                            <li><span>Camera Resolution</span><span>16MP (4656×3496)</span></li>
                            <li><span>Focus Range</span><span>0-30 (programmable)</span></li>
                            <li><span>Tool Change Time</span><span><5 seconds</span></li>
                            <li><span>Communication</span><span>CAN, MQTT, Serial, HTTP</span></li>
                            <li><span>Firmware</span><span>Klipper-based</span></li>
			</font>
			</ul>
                    </div>
                    
                    <div class="specs-visual fade-in">
                        <h4>Multi-Protocol Architecture</h4>
                        <p>CAN Bus • MQTT • Serial • HTTP</p>
                        <div style="margin: 20px 0; font-size: 3rem;">⚙️</div>
                        <p>Unified tool framework with real-time sensor monitoring and automatic error recovery</p>
                    </div>
                </div>
            </div>
        </section>

        <section id="github" class="github-section">
            <div class="container">
                <div class="github-content fade-in">
                    <h3>Built on Open Source Innovation</h3>
                    <p>Our expertise comes from deep involvement in developing and implementing the open-source Rister toolchanger platform. We contribute to the community while offering professional implementation and support services.</p>
                    
                    <a href="https://github.com/htsrjdrouse/rister-toolchanger" class="github-button" target="_blank">View on GitHub</a>
                    <a href="#contact" class="github-button">Professional Implementation</a>
                </div>
            </div>
        </section>

        <section id="contact" class="contact-section">
            <div class="container">
                <div class="contact-grid">
                    <div class="fade-in">
                        <h3>Get Your Custom Solution</h3>
                        <p style="margin-bottom: 30px; color: #718096; font-size: 1.1rem;">
                            Ready to implement advanced multi-modal manufacturing? Our team brings deep expertise in integrating 3D printing, liquid handling, and imaging systems using the innovative Rister architecture.
                        </p>
                        
                        <div style="margin-bottom: 20px;">
                            <h4 style="color: #667eea; margin-bottom: 10px;">Use Cases We're Developing:</h4>
                            <ul style="color: #718096; line-height: 1.8;">
                                <li>FDM printing with integrated liquid dispensing</li>
                                <li>Automated pipette loading and aspiration</li>
                                <li>Precision dispensing and washing protocols</li>
                                <li>Real-time quality control imaging</li>
                                <li>Custom biotech and research applications</li>
                            </ul>
                        </div>
                        
                        <div>
                            <h4 style="color: #667eea; margin-bottom: 10px;">Markets We Serve:</h4>
                            <ul style="color: #718096; line-height: 1.8;">
                                <li><strong>DIY Personal Manufacturing:</strong> Advanced multi-modal systems for makers and hobbyists</li>
                                <li><strong>Biotechnology:</strong> Automated liquid handling and biotech research applications</li>
                                <li><strong>Semiconductor Manufacturing:</strong> Precision tooling and specialized process control</li>
                                <li><strong>Academic Research:</strong> Custom implementations for research institutions</li>
                                <li><strong>Custom Manufacturing:</strong> Specialized solutions for unique requirements</li>
                            </ul>
                        </div>
                    </div>
                    
                    <div class="contact-form fade-in">
                        <h4 style="margin-bottom: 20px; color: #2d3748;">Request a Quote</h4>
                        <form action=contact_handler.php method=POST>
                            <!-- Honeypot field - hidden from humans, visible to bots -->
                           <input type="text" id="website" name="website" style="display: none;" tabindex="-1" autocomplete="off">
                            
                            <div class="form-group">
                                <label for="name">Name *</label>
                                <input type="text" id="name" name="name" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email *</label>
                                <input type="email" id="email" name="email" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="company">Company/Institution</label>
                                <input type="text" id="company" name="company">
                            </div>
                            
                            <div class="form-group">
                                <label for="application">Application Type</label>
                                <select id="application" name="application">
                                    <option value="">Select an application</option>
                                    <option value="custom-ui">Custom User Interface Development</option>
                                    <option value="biotechnology">Biotechnology Applications</option>
                                    <option value="semiconductor">Semiconductor Manufacturing</option>
                                    <option value="custom-implementation">Custom Implementation</option>
                                    <option value="training-support">Training & Support</option>
                                    <option value="other">Other</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="message">Project Details *</label>
                                <textarea id="message" name="message" rows="4" placeholder="Tell us about your project requirements, timeline, and any specific needs..." required></textarea>
                            </div>
                            
                            <div style="margin-bottom: 20px; font-size: 0.9rem; color: #718096;">
                                <p>* Required fields</p>
                                <p>By submitting this form, you agree to be contacted regarding your project inquiry. We respect your privacy and will not share your information.</p>
                            </div>
                            
                            <button type="submit" class="submit-btn">Send Quote Request</button>
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <footer>
        <div class="container">
            <p>&copy; 2025 HTS Resources. Expert Multi-Modal Manufacturing Implementation.</p>
            <p style="margin-top: 10px; opacity: 0.7;">Built on Open Source Innovation • Professional Implementation & Support</p>
        </div>
    </footer>

    <script>
        // Mobile menu toggle
        const mobileToggle = document.getElementById('mobileToggle');
        const navLinks = document.getElementById('navLinks');
        
        mobileToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');
        });

        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                    // Close mobile menu if open
                    navLinks.classList.remove('active');
                }
            });
        });

        // Fade in animation on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                }
            });
        }, observerOptions);

        // Observe all fade-in elements
        document.querySelectorAll('.fade-in').forEach(el => {
            observer.observe(el);
        });

        // Header background on scroll
        window.addEventListener('scroll', () => {
            const header = document.querySelector('header');
            if (window.scrollY > 100) {
                header.style.background = 'rgba(255, 255, 255, 0.98)';
            } else {
                header.style.background = 'rgba(255, 255, 255, 0.95)';
            }
        });

        // Handle form submission response messages
        document.addEventListener('DOMContentLoaded', function() {
            // Check for URL parameters indicating form submission result
            const urlParams = new URLSearchParams(window.location.search);
            const status = urlParams.get('status');
            const message = urlParams.get('message');
            
            if (status && message) {
                const decodedMessage = decodeURIComponent(message);
                
                if (status === 'success') {
                    // Show success message
                    showNotification(decodedMessage, 'success');
                    // Clear the form if it exists
                    const form = document.querySelector('form');
                    if (form) form.reset();
                } else if (status === 'error') {
                    // Show error message
                    showNotification(decodedMessage, 'error');
                }
                
                // Clean up URL by removing parameters
                const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.replaceState({}, document.title, cleanUrl);
            }
        });
        
        // Function to show notifications
        function showNotification(message, type) {
            // Create notification element
            const notification = document.createElement('div');
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 15px 20px;
                border-radius: 10px;
                color: white;
                font-weight: 600;
                z-index: 10000;
                max-width: 400px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                animation: slideIn 0.3s ease-out;
                background: ${type === 'success' ? '#10B981' : '#EF4444'};
            `;
            
            notification.textContent = message;
            document.body.appendChild(notification);
            
            // Add slide in animation
            const style = document.createElement('style');
            style.textContent = `
                @keyframes slideIn {
                    from { transform: translateX(100%); opacity: 0; }
                    to { transform: translateX(0); opacity: 1; }
                }
            `;
            document.head.appendChild(style);
            
            // Remove notification after 5 seconds
            setTimeout(() => {
                notification.style.animation = 'slideIn 0.3s ease-out reverse';
                setTimeout(() => {
                    if (notification.parentNode) {
                        notification.parentNode.removeChild(notification);
                    }
                }, 300);
            }, 5000);
        }

        // Initialize first fade-in element
        document.querySelector('.fade-in').classList.add('visible');
    </script>
</body>
</html>
