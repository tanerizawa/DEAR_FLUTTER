#!/usr/bin/env python3
"""
Enhanced Stealth YouTube Extractor Monitoring Script

This script provides comprehensive monitoring and management capabilities
for the stealth YouTube extraction system.
"""

import asyncio
import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import aiohttp
import argparse
import sys
import os

class StealthExtractorMonitor:
    """Monitor and manage the stealth YouTube extractor"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url.rstrip("/")
        self.api_base = f"{self.base_url}/api/v1/music"
        
    async def get_status(self) -> Dict:
        """Get current stealth extractor status"""
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.api_base}/stealth-status") as response:
                if response.status == 200:
                    return await response.json()
                else:
                    raise Exception(f"Failed to get status: {response.status}")
    
    async def get_performance_metrics(self) -> Dict:
        """Get detailed performance metrics"""
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.api_base}/performance-metrics") as response:
                if response.status == 200:
                    return await response.json()
                else:
                    raise Exception(f"Failed to get metrics: {response.status}")
    
    async def rotate_session(self) -> Dict:
        """Force session rotation"""
        async with aiohttp.ClientSession() as session:
            async with session.post(f"{self.api_base}/rotate-stealth-session") as response:
                if response.status == 200:
                    return await response.json()
                else:
                    raise Exception(f"Failed to rotate session: {response.status}")
    
    async def clear_failed_strategies(self) -> Dict:
        """Clear failed strategies"""
        async with aiohttp.ClientSession() as session:
            async with session.post(f"{self.api_base}/clear-failed-strategies") as response:
                if response.status == 200:
                    return await response.json()
                else:
                    raise Exception(f"Failed to clear strategies: {response.status}")
    
    async def test_extraction(self, youtube_url: str, stealth_mode: bool = True, use_proxy: bool = False) -> Dict:
        """Test extraction with specified parameters"""
        payload = {
            "youtube_url": youtube_url,
            "stealth_mode": stealth_mode,
            "use_proxy": use_proxy
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(
                f"{self.api_base}/extract-audio",
                json=payload,
                timeout=aiohttp.ClientTimeout(total=300)
            ) as response:
                if response.status == 200:
                    return await response.json()
                else:
                    error_text = await response.text()
                    raise Exception(f"Extraction failed: {response.status} - {error_text}")
    
    def format_status_report(self, status: Dict) -> str:
        """Format status information for display"""
        report = []
        report.append("=" * 60)
        report.append("STEALTH YOUTUBE EXTRACTOR STATUS")
        report.append("=" * 60)
        
        # Session Information
        report.append(f"Session ID: {status.get('session_id', 'Unknown')}")
        report.append(f"Session Duration: {status.get('session_duration', 0):.1f} seconds")
        report.append(f"Requests This Session: {status.get('requests_this_session', 0)}")
        report.append(f"Max Requests: {status.get('max_requests_per_session', 0)}")
        
        # Detection and Health
        report.append(f"Bot Detection Count: {status.get('bot_detection_count', 0)}")
        report.append(f"Health Score: {status.get('health_score', 0):.2f}/1.0")
        report.append(f"Should Rotate: {'Yes' if status.get('should_rotate', False) else 'No'}")
        
        # Performance
        report.append(f"Min Request Interval: {status.get('min_request_interval', 0):.1f}s")
        report.append(f"Adaptive Delay Multiplier: {status.get('adaptive_delay_multiplier', 1):.2f}")
        report.append(f"Cache Size: {status.get('cache_size', 0)} entries")
        
        # Failed Strategies
        failed_strategies = status.get('failed_strategies', [])
        if failed_strategies:
            report.append(f"Failed Strategies: {', '.join(failed_strategies)}")
        else:
            report.append("Failed Strategies: None")
        
        # Browser Fingerprint
        fingerprint = status.get('browser_fingerprint', {})
        if fingerprint:
            report.append("Browser Fingerprint:")
            report.append(f"  Platform: {fingerprint.get('platform', 'Unknown')}")
            resolution = fingerprint.get('screen_resolution', {})
            if resolution:
                report.append(f"  Screen: {resolution.get('width', 0)}x{resolution.get('height', 0)}")
            report.append(f"  Canvas Hash: {fingerprint.get('canvas_hash', 'Unknown')}")
            report.append(f"  Touch Support: {fingerprint.get('touch_support', False)}")
        
        return "\n".join(report)
    
    def format_metrics_report(self, metrics: Dict) -> str:
        """Format performance metrics for display"""
        report = []
        report.append("=" * 60)
        report.append("PERFORMANCE METRICS")
        report.append("=" * 60)
        
        # Session Metrics
        session_metrics = metrics.get('session_metrics', {})
        report.append("Session Metrics:")
        report.append(f"  Duration: {session_metrics.get('duration', 0):.1f} seconds")
        report.append(f"  Requests: {session_metrics.get('requests_count', 0)}")
        report.append(f"  Requests/Hour: {session_metrics.get('requests_per_hour', 0):.1f}")
        report.append(f"  Health Score: {session_metrics.get('health_score', 0):.2f}")
        
        # Detection Metrics
        detection_metrics = metrics.get('detection_metrics', {})
        report.append("Detection Metrics:")
        report.append(f"  Bot Detections: {detection_metrics.get('bot_detection_count', 0)}")
        report.append(f"  Delay Multiplier: {detection_metrics.get('adaptive_delay_multiplier', 1):.2f}")
        report.append(f"  Request Interval: {detection_metrics.get('min_request_interval', 0):.1f}s")
        report.append(f"  Failed Strategies: {detection_metrics.get('failed_strategies_count', 0)}")
        
        # Cache Metrics
        cache_metrics = metrics.get('cache_metrics', {})
        report.append("Cache Metrics:")
        report.append(f"  Cache Size: {cache_metrics.get('cache_size', 0)}")
        report.append(f"  Hit Rate: {cache_metrics.get('cache_hit_rate', 0):.2%}")
        
        return "\n".join(report)
    
    async def monitor_continuous(self, interval: int = 30):
        """Continuously monitor the extractor"""
        print("Starting continuous monitoring...")
        print(f"Monitoring interval: {interval} seconds")
        print("Press Ctrl+C to stop")
        
        try:
            while True:
                try:
                    status = await self.get_status()
                    
                    # Clear screen
                    os.system('clear' if os.name == 'posix' else 'cls')
                    
                    # Display current time
                    print(f"Last Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                    print()
                    
                    # Display status
                    print(self.format_status_report(status))
                    
                    # Check health and provide recommendations
                    health_score = status.get('health_score', 0)
                    bot_detection_count = status.get('bot_detection_count', 0)
                    
                    print("\n" + "=" * 60)
                    print("RECOMMENDATIONS")
                    print("=" * 60)
                    
                    if health_score < 0.3:
                        print("⚠️  LOW HEALTH: Consider rotating session or checking proxies")
                    elif health_score < 0.6:
                        print("⚡ MODERATE HEALTH: Monitor closely")
                    else:
                        print("✅ GOOD HEALTH: Operating normally")
                    
                    if bot_detection_count > 5:
                        print("🤖 HIGH BOT DETECTION: Immediate session rotation recommended")
                    elif bot_detection_count > 2:
                        print("🚨 ELEVATED DETECTION: Monitor and consider rotation")
                    
                    if status.get('should_rotate', False):
                        print("🔄 SESSION ROTATION: Recommended")
                    
                    await asyncio.sleep(interval)
                    
                except Exception as e:
                    print(f"Error during monitoring: {e}")
                    await asyncio.sleep(interval)
                    
        except KeyboardInterrupt:
            print("\nMonitoring stopped.")
    
    async def health_check(self) -> bool:
        """Perform comprehensive health check"""
        try:
            print("Performing health check...")
            
            # Get status
            status = await self.get_status()
            health_score = status.get('health_score', 0)
            
            # Get metrics
            metrics = await self.get_performance_metrics()
            
            print(f"✅ API Connection: OK")
            print(f"✅ Health Score: {health_score:.2f}")
            
            # Check various health indicators
            issues = []
            
            if health_score < 0.3:
                issues.append("Low health score")
            
            if status.get('bot_detection_count', 0) > 5:
                issues.append("High bot detection count")
            
            if status.get('cache_size', 0) > 1000:
                issues.append("Large cache size")
            
            failed_strategies = status.get('failed_strategies', [])
            if len(failed_strategies) > 5:
                issues.append("Many failed strategies")
            
            if issues:
                print("⚠️  Issues found:")
                for issue in issues:
                    print(f"   - {issue}")
                return False
            else:
                print("✅ All checks passed")
                return True
                
        except Exception as e:
            print(f"❌ Health check failed: {e}")
            return False

async def main():
    parser = argparse.ArgumentParser(description="Monitor Stealth YouTube Extractor")
    parser.add_argument("--url", default="http://localhost:8000", help="Base URL of the API")
    parser.add_argument("--command", choices=['status', 'metrics', 'rotate', 'clear', 'test', 'monitor', 'health'], 
                       default='status', help="Command to execute")
    parser.add_argument("--test-url", help="YouTube URL for testing extraction")
    parser.add_argument("--interval", type=int, default=30, help="Monitoring interval in seconds")
    parser.add_argument("--stealth", action='store_true', help="Use stealth mode for testing")
    parser.add_argument("--proxy", action='store_true', help="Use proxy for testing")
    
    args = parser.parse_args()
    
    monitor = StealthExtractorMonitor(args.url)
    
    try:
        if args.command == 'status':
            status = await monitor.get_status()
            print(monitor.format_status_report(status))
            
        elif args.command == 'metrics':
            metrics = await monitor.get_performance_metrics()
            print(monitor.format_metrics_report(metrics))
            
        elif args.command == 'rotate':
            result = await monitor.rotate_session()
            print(f"Session rotated: {result}")
            
        elif args.command == 'clear':
            result = await monitor.clear_failed_strategies()
            print(f"Failed strategies cleared: {result}")
            
        elif args.command == 'test':
            if not args.test_url:
                print("Error: --test-url is required for testing")
                sys.exit(1)
            
            print(f"Testing extraction of: {args.test_url}")
            print(f"Stealth mode: {args.stealth}")
            print(f"Proxy mode: {args.proxy}")
            
            result = await monitor.test_extraction(args.test_url, args.stealth, args.proxy)
            print(f"Test result: {json.dumps(result, indent=2)}")
            
        elif args.command == 'monitor':
            await monitor.monitor_continuous(args.interval)
            
        elif args.command == 'health':
            is_healthy = await monitor.health_check()
            sys.exit(0 if is_healthy else 1)
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
