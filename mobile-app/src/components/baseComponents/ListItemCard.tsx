import React from 'react';
import {Pressable, Text, View, StyleSheet} from 'react-native';
import {ChevronRight} from 'lucide-react-native';

interface InfoCardProps {
  icon?: React.ReactNode;
  title: string;
  subtitle?: string;
  onPress?: () => void;
}

const InfoCard: React.FC<InfoCardProps> = ({
  icon,
  title,
  subtitle,
  onPress,
}) => {
  return (
    <Pressable onPress={onPress} style={styles.container}>
      <View className="flex-row items-center space-x-3 pt-1 pb-1 pl-3 pr-4">
        {icon}
        <View className="pl-2">
          <Text className="text-text-primary text-lg font-medium">{title}</Text>
          {subtitle ? (
            <Text className="text-text-tertiary font-normal text-sm">
              {subtitle}
            </Text>
          ) : null}
        </View>
      </View>
      <ChevronRight size={20} color="#6b7280" />
    </Pressable>
  );
};

export default InfoCard;

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderWidth: 1,
    borderColor: 'rgba(0, 10, 15, 0.08)',
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowOffset: {width: 0, height: 1},
    shadowRadius: 2,
    elevation: 1,
  },
});
