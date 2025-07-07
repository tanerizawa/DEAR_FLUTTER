// lib/presentation/home/widgets/enhanced_radio_section.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/radio_station.dart';
import 'package:dear_flutter/presentation/home/cubit/enhanced_radio_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/enhanced_radio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class EnhancedRadioSection extends StatelessWidget {
  const EnhancedRadioSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EnhancedRadioCubit>(),
      child: const _EnhancedRadioContent(),
    );
  }
}

class _EnhancedRadioContent extends StatelessWidget {
  const _EnhancedRadioContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnhancedRadioCubit, EnhancedRadioState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A1A),
                Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, state),
              if (state.status == EnhancedRadioStatus.loaded && state.currentStation == null)
                _buildStationSelector(context, state),
              if (state.currentStation != null)
                _buildNowPlaying(context, state),
              if (state.status == EnhancedRadioStatus.playing && state.currentPlaylist.isNotEmpty)
                _buildMiniPlaylist(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, EnhancedRadioState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button to show station list when a station is selected
          if (state.currentStation != null)
            IconButton(
              onPressed: () => context.read<EnhancedRadioCubit>().showStationList(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
          if (state.currentStation != null) const SizedBox(width: 8),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')).withOpacity(0.2),
            ),
            child: Icon(
              Icons.radio,
              color: Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.currentStation?.name.replaceAll(RegExp(r'[^\w\s]'), '').trim() ?? 'Dear Radio',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getStatusText(state.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationSelector(BuildContext context, EnhancedRadioState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Pilih Stasiun Radio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.availableStations.length,
            itemBuilder: (context, index) {
              final station = state.availableStations[index];
              return _buildStationCard(context, station);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStationCard(BuildContext context, RadioStation station) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => context.read<EnhancedRadioCubit>().playRadioStation(station),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.1),
                Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      _getStationEmoji(station.category),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  station.name.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${station.listeners}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlaying(BuildContext context, EnhancedRadioState state) {
    final station = state.currentStation!;
    
    return Column(
      children: [
        // Station info section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        _getStationEmoji(station.category),
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          station.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _buildLiveIndicator(context, station),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Player controls
              _buildPlayerControls(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(BuildContext context, EnhancedRadioState state) {
    final isPlaying = state.status == EnhancedRadioStatus.playing;
    final isLoading = state.status == EnhancedRadioStatus.loading;
    final canPlay = state.currentStation != null && !isLoading;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Refresh button
        IconButton(
          onPressed: isLoading ? null : () => context.read<EnhancedRadioCubit>().refreshCurrentStation(),
          icon: Icon(
            Icons.refresh,
            color: Colors.white70,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Main play/pause button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')),
                Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')).withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canPlay ? () => context.read<EnhancedRadioCubit>().togglePlayPause() : null,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 64,
                height: 64,
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Volume/Settings button
        IconButton(
          onPressed: () => _showVolumeControl(context),
          icon: Icon(
            Icons.volume_up,
            color: Colors.white70,
            size: 20,
          ),
        ),
      ],
    );
  }
  
  void _showVolumeControl(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Volume Control',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Volume control akan diimplementasikan di update selanjutnya.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator(BuildContext context, RadioStation station) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: station.isLive ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          station.isLive ? 'LIVE' : 'OFFLINE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: station.isLive ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.people,
          size: 14,
          color: Colors.white60,
        ),
        const SizedBox(width: 4),
        Text(
          '${station.listeners} pendengar',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniPlaylist(BuildContext context, EnhancedRadioState state) {
    final playlist = state.currentPlaylist.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Sedang Diputar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showFullPlaylist(context, state),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')),
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            final track = playlist[index];
            final isCurrentTrack = index == state.currentTrackIndex;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isCurrentTrack 
                    ? Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')).withOpacity(0.1)
                    : Colors.transparent,
                border: isCurrentTrack 
                    ? Border.all(
                        color: Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')).withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  if (isCurrentTrack)
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.graphic_eq,
                        color: Color(_parseHexColor(state.currentStation?.color ?? '#1DB954')),
                        size: 16,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isCurrentTrack ? FontWeight.w600 : FontWeight.normal,
                            color: isCurrentTrack 
                                ? Color(_parseHexColor(state.currentStation?.color ?? '#1DB954'))
                                : Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (track.artist?.isNotEmpty == true)
                          Text(
                            track.artist!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '3:45', // Default duration since AudioTrack doesn't have duration
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showFullPlaylist(BuildContext context, EnhancedRadioState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FullPlaylistSheet(state: state),
    );
  }

  String _getStatusText(EnhancedRadioStatus status) {
    switch (status) {
      case EnhancedRadioStatus.initial:
        return 'Memuat stasiun...';
      case EnhancedRadioStatus.loaded:
        return 'Pilih stasiun untuk memulai';
      case EnhancedRadioStatus.loading:
        return 'Menghubungkan...';
      case EnhancedRadioStatus.playing:
        return 'Sedang diputar';
      case EnhancedRadioStatus.paused:
        return 'Dijeda';
      case EnhancedRadioStatus.stopped:
        return 'Terhenti';
      case EnhancedRadioStatus.error:
        return 'Terjadi kesalahan';
    }
  }

  String _getStationEmoji(String category) {
    final radioCategory = RadioCategory.values.firstWhere(
      (cat) => cat.id == category,
      orElse: () => RadioCategory.pop,
    );
    return radioCategory.emoji;
  }

  int _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }


}

class _FullPlaylistSheet extends StatelessWidget {
  final EnhancedRadioState state;

  const _FullPlaylistSheet({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Playlist ${state.currentStation?.name ?? ""}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.currentPlaylist.length,
              itemBuilder: (context, index) {
                final track = state.currentPlaylist[index];
                final isCurrentTrack = index == state.currentTrackIndex;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isCurrentTrack 
                        ? const Color(0xFF1DB954).withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    border: isCurrentTrack 
                        ? Border.all(color: const Color(0xFF1DB954).withOpacity(0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: isCurrentTrack ? FontWeight.w600 : FontWeight.normal,
                                color: isCurrentTrack ? const Color(0xFF1DB954) : Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (track.artist?.isNotEmpty == true)
                              Text(
                                track.artist!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white60,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (isCurrentTrack)
                        const Icon(
                          Icons.graphic_eq,
                          color: Color(0xFF1DB954),
                          size: 20,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
