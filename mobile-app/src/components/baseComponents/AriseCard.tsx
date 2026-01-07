import classNames from 'classnames';
import React from 'react';
import {View, ViewProps} from 'react-native';

interface AriseCardProps extends ViewProps {
  children: React.ReactNode;
  className?: string;
}
const AriseCard: React.FC<AriseCardProps> = ({
  children,
  className,
  ...props
}) => {
  const combinedClassNames = classNames(
    'rounded-xl bg-dark-elavation-1  h-fit',
    className,
  );

  return (
    <View className={combinedClassNames} {...props}>
      {children}
    </View>
  );
};

export default AriseCard;
