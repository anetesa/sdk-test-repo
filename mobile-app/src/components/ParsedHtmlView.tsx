// ParsedHtmlView.tsx
import React, {useEffect, useState} from 'react';
import {ScrollView, View, Text, ActivityIndicator} from 'react-native';
import {logger} from '@/utils/logger';

type TextSegment = {
  text: string;
  bold?: boolean;
};

type Node = {
  type: string;
  segments: TextSegment[];
};

interface ParsedHtmlViewProps {
  /** URL to fetch HTML from */
  url: string;
  /** Optional map of tag styles (e.g., { h1: { ... }, p: { ... } }) */
  tagStyles?: Record<string, object>;
  /** Optional error callback */
  onError?: (err: Error) => void;
  /** Optional className */
  className?: string;
}
interface styleType {
  fontSize: number;
  lineHeight: number;
  marginBottom: number;
  fontWeight?: string;
  paddingTop?: number;
}

export const decodeHtmlEntities = (text: string) => {
  return text
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/&nbsp;/g, ' ');
};

const parseHtmlContent = (html: string): TextSegment[] => {
  const segments: TextSegment[] = [];

  // First, handle line breaks by splitting on <br> tags
  const parts = html.split(/<br\s*\/?>/gi);

  parts.forEach((part, partIndex) => {
    if (!part.trim()) {
      if (partIndex < parts.length - 1) {
        segments.push({text: '\n'});
      }
      return;
    }

    // Process each part for <strong> tags
    const strongRegex = /<strong[^>]*>([\s\S]*?)<\/strong>/gi;
    let lastIndex = 0;
    let match;

    while ((match = strongRegex.exec(part)) !== null) {
      // Add text before the strong tag (if any)
      if (match.index > lastIndex) {
        const beforeText = part.substring(lastIndex, match.index);
        const cleanText = beforeText.replace(/<[^>]+>/g, '').trim();
        if (cleanText) {
          segments.push({text: decodeHtmlEntities(cleanText)});
        }
      }

      // Add the strong text
      const strongText = match[1].replace(/<[^>]+>/g, '').trim();
      if (strongText) {
        segments.push({
          text: decodeHtmlEntities(strongText),
          bold: true,
        });
      }

      lastIndex = match.index + match[0].length;
    }

    // Add remaining text after the last strong tag
    if (lastIndex < part.length) {
      const remainingText = part.substring(lastIndex);
      const cleanText = remainingText.replace(/<[^>]+>/g, '').trim();
      if (cleanText) {
        segments.push({text: decodeHtmlEntities(cleanText)});
      }
    }

    // Add line break after each part (except the last one)
    if (partIndex < parts.length - 1) {
      segments.push({text: '\n'});
    }
  });

  return segments.filter(segment => segment.text.length > 0);
};

const ParsedHtmlView: React.FC<ParsedHtmlViewProps> = ({
  url,
  tagStyles = {},
  onError,
  className,
}) => {
  const [nodes, setNodes] = useState<Node[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(url)
      .then(res => res.text())
      .then(html => {
        // 1) Isolate the relevant block
        const matchSection = html.match(
          /<div[^>]*class="[^"]*\bwp-block-cover__inner-container\b[^"]*"[^>]*>[\s\S]*?<\/div>\s*([\s\S]*?)<\/main>/i,
        );
        const inner = matchSection ? matchSection[1] : html;

        // 2) Extract h1-h6 and p tags
        const regex = /<(h[1-6]|p)[^>]*>([\s\S]*?)<\/\1>/gi;
        const extracted: Node[] = [];
        let m: RegExpExecArray | null;
        while ((m = regex.exec(inner)) !== null) {
          const segments = parseHtmlContent(m[2]);
          if (segments.length > 0) {
            extracted.push({type: m[1], segments});
          }
        }

        setNodes(extracted);
        setLoading(false);
      })
      .catch(err => {
        logger.error(err, 'Error loading HTML content');
        onError?.(err);
        setLoading(false);
      });
  }, [url, onError]);

  if (loading) {
    return (
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <ScrollView className={className} style={{flex: 1, padding: 16}}>
      {nodes.map((node, idx) => {
        let baseStyle: styleType = {
          fontSize: 16,
          lineHeight: 22,
          marginBottom: 8,
        };
        if (node.type === 'h1') {
          baseStyle = {
            fontSize: 24,
            fontWeight: 'bold',
            marginBottom: 12,
            lineHeight: 22,
            paddingTop: 10,
          };
        } else if (node.type === 'h2') {
          baseStyle = {
            fontSize: 20,
            fontWeight: '600',
            lineHeight: 22,
            marginBottom: 10,
            paddingTop: 10,
          };
        }

        const combined = [baseStyle, tagStyles[node.type]];

        return (
          <Text key={idx} style={combined}>
            {node.segments.map((segment, segIdx) => {
              if (segment.text === '\n') {
                return '\n';
              }

              if (segment.bold) {
                return (
                  <Text key={segIdx} style={{fontWeight: 'bold'}}>
                    {segment.text}
                  </Text>
                );
              }

              return segment.text;
            })}
          </Text>
        );
      })}
    </ScrollView>
  );
};

export default ParsedHtmlView;
