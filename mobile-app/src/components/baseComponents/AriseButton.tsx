import classNames from 'classnames';
import React from 'react';
import {Pressable, Text, PressableProps, ActivityIndicator} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import {COLORS, GRADIENT_COLORS} from '@/constants/colors';
import {SHADOW_PROPERTIES} from '@/constants/dimensions';

interface AriseButtonProps extends PressableProps {
  type?: 'primary' | 'secondary' | 'outline' | 'danger';
  title: string;
  loading?: boolean;
  error?: boolean;
  nativeID?: string;
  accessibilityLabel?: string;
}

const AriseButton: React.FC<AriseButtonProps> = ({
  type = 'primary',
  title,
  loading,
  error,
  nativeID,
  accessibilityLabel,
  ...props
}) => {
  const buttonClass = classNames('button', {
    'bg-gray-300': type === 'secondary',
    'bg-elevation-01': type === 'outline',
    'bg-elevation-04': props.disabled,
    'bg-white': type === 'danger',
  });

  const textClass = classNames('button', {
    'text-white': type === 'primary',
    'text-black': type === 'secondary' || type === 'outline',
    'text-text-faded': props.disabled,
    'text-error-dark': type === 'danger',
  });

  if (type === 'primary') {
    return (
      <Pressable
        {...props}
        testID={`arise-button-${title}`}
        // @ts-ignore - nativeID is supported but not in types
        nativeID={nativeID}
        accessibilityLabel={accessibilityLabel || title}
        className={`flex justify-center items-center h-16 rounded-2xl ${
          loading || props.disabled ? 'bg-elevation-04' : ''
        }`}>
        {({pressed}) => {
          if (loading) {
            return (
              <ActivityIndicator size="small" color={COLORS.NEUTRAL_GRAY} />
            );
          }
          if (props.disabled) {
            return (
              <Text
                className={`flex text-lg font-medium line-height-[28px]${textClass}`}>
                {title}
              </Text>
            );
          }
          return (
            <LinearGradient
              colors={
                pressed
                  ? [...GRADIENT_COLORS.PRIMARY_PRESSED]
                  : [...GRADIENT_COLORS.PRIMARY]
              }
              start={{x: 0, y: 0}}
              end={{x: 0, y: 1}}
              className="flex justify-center items-center h-full w-full rounded-2xl">
              <Text
                className={`flex text-lg font-medium line-height-[28px] ${textClass}`}>
                {title}
              </Text>
            </LinearGradient>
          );
        }}
      </Pressable>
    );
  }

  return (
    <Pressable
      disabled={loading || props.disabled}
      accessibilityState={{disabled: !!(loading || props.disabled)}}
      {...props}
      testID={`arise-button-${title}`}
      // @ts-ignore - nativeID is supported but not in types
      nativeID={nativeID}
      accessibilityLabel={accessibilityLabel || title}
      className={classNames(
        'flex justify-center items-center h-16 rounded-2xl border border-elevation-08',
        buttonClass,
        {'bg-elevation-04': loading},
        {'border-error-3': type === 'danger'},
      )}
      style={
        type === 'danger'
          ? [(props as any).style]
          : [
              {
                shadowColor: COLORS.BLACK,
                shadowOffset: SHADOW_PROPERTIES.SHADOW_OFFSET,
                shadowOpacity: SHADOW_PROPERTIES.SHADOW_OPACITY,
                shadowRadius: SHADOW_PROPERTIES.SHADOW_RADIUS,
                elevation: SHADOW_PROPERTIES.ELEVATION,
              },
              (props as any).style,
            ]
      }>
      {loading ? (
        <ActivityIndicator size="small" />
      ) : (
        <Text
          className={classNames(
            'flex text-lg font-medium line-height-[28px]',
            textClass,
          )}>
          {title}
        </Text>
      )}
    </Pressable>
  );
};

export default AriseButton;
